//
//  NearbyCardExchangeView.swift
//  Potential Scanner
//
//  근거리 카드 교환. 배틀과 동일한 MultipeerService(연결·keep-alive 포함)를 재사용하고,
//  판정 없이 서로 카드를 주고받기만 한다. 받은 카드는 "받기"를 눌러야 내 보관함에 저장된다.
//

import MultipeerConnectivity
import SwiftData
import SwiftUI

struct NearbyCardExchangeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScanCard.scannedAt, order: .reverse) private var cards: [ScanCard]
    @State private var service = MultipeerService(mode: .exchange)

    @State private var myCard: BattleContender?
    @State private var oppCard: BattleContender?
    @State private var didSave = false

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            // 내가 이미 필요한 걸 다 들고 있는 단계(받을지 판단 / 저장 완료)는 연결
            // 상태와 무관하게 유지한다 — 배틀 리빌과 같은 이유다. 여기서 사람이 카드를
            // 들여다보며 고민하는 동안 링크가 잠깐 끊겼다고 화면이 통째로 날아가면 안 된다.
            if didSave {
                savedView
            } else if let oppCard, myCard != nil {
                offerReceivedView(oppCard)
            } else {
                switch service.state {
                case .idle:
                    roleSelect
                case .advertising:
                    statusView(messageKey: "ui.multiBattle.hosting")
                case .browsing:
                    joiningView
                case .connecting:
                    statusView(messageKey: "ui.multiBattle.connecting")
                case .connected:
                    connectedView
                }
            }
        }
        .psNavigationTitle("ui.exchange.title")
        .onAppear {
            service.onReceiveMessage = handle
        }
        // onDisappear로 disconnect하지 않는다 — 배틀 화면과 동일한 이유(리스트 조작 중
        // onDisappear가 튀어 연결이 끊기는 문제)로, 정리는 취소/종료 버튼에서만 한다.
    }

    // MARK: - 역할 선택 / 연결 단계 (배틀 화면과 동일한 패턴)

    private var roleSelect: some View {
        VStack(spacing: 16) {
            PSButton(title: String(localized: String.LocalizationValue("ui.exchange.hostButton"))) {
                service.host()
            }
            PSButton(
                title: String(localized: String.LocalizationValue("ui.exchange.joinButton")),
                isProminent: false
            ) {
                service.join()
            }
        }
        .padding(.horizontal, 40)
    }

    private func statusView(messageKey: String) -> some View {
        VStack(spacing: 20) {
            ProgressView()
            Text(String(localized: String.LocalizationValue(messageKey)))
                .font(PSTypography.body)
                .foregroundStyle(PSColor.soft)
            cancelButton
        }
        .padding(40)
    }

    private var joiningView: some View {
        VStack(spacing: 16) {
            Text(String(localized: String.LocalizationValue("ui.multiBattle.browsing")))
                .font(PSTypography.body)
                .foregroundStyle(PSColor.soft)

            if service.discoveredPeers.isEmpty {
                ProgressView()
                Text(String(localized: String.LocalizationValue("ui.multiBattle.noPeers")))
                    .font(.caption)
                    .foregroundStyle(PSColor.soft)
            } else {
                ForEach(service.discoveredPeers, id: \.self) { peer in
                    PSButton(title: peer.displayName) {
                        service.invite(peer)
                    }
                }
            }

            cancelButton
        }
        .padding(.horizontal, 40)
    }

    // MARK: - 연결됨: 카드 선택 → 수신 대기 → 미리보기/받기 → 완료

    /// 받기 판단/저장 완료 단계는 body 상단에서 처리한다. 여기선 아직 내 카드를
    /// 안 보낸 단계만 담당 — 상대 카드가 먼저 도착했더라도 내 카드를 고르는 게 먼저다.
    /// (예전엔 상대 카드가 먼저 오면 선택 화면이 사라져서, 받기만 하고 내 카드는
    ///  영영 안 나가는 일방 교환이 됐다.)
    @ViewBuilder
    private var connectedView: some View {
        if myCard != nil {
            statusView(messageKey: "ui.exchange.waitingOpponentCard")
        } else {
            pickPromptView
        }
    }

    private var pickPromptView: some View {
        VStack(spacing: 12) {
            Text(String(
                format: String(localized: String.LocalizationValue("ui.multiBattle.connectedTo")),
                service.connectedPeerName ?? ""
            ))
            .font(.caption)
            .foregroundStyle(PSColor.soft)
            .multilineTextAlignment(.center)
            .padding(.top, 8)

            Text(String(localized: String.LocalizationValue("ui.exchange.pickYourCard")))
                .font(PSTypography.pageTitle)
                .foregroundStyle(PSColor.ink)

            if cards.isEmpty {
                Text(String(localized: String.LocalizationValue("ui.battle.needCards")))
                    .font(.caption)
                    .foregroundStyle(PSColor.soft)
                Spacer()
            } else {
                List {
                    ForEach(cards) { card in
                        Button {
                            selectCard(card)
                        } label: {
                            HStack(spacing: 12) {
                                cardThumbnail(card)
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.displayName)
                                        .font(PSTypography.body)
                                        .foregroundStyle(PSColor.ink)
                                    Text("\(card.power)")
                                        .font(.caption)
                                        .foregroundStyle(PSColor.soft)
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }

            cancelButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func offerReceivedView(_ contender: BattleContender) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(String(localized: String.LocalizationValue("ui.exchange.offerReceivedTitle")))
                    .font(PSTypography.pageTitle)
                    .foregroundStyle(PSColor.ink)

                ScaledCardArtboard(content: CardArtboardContent(contender: contender))
                    .frame(maxWidth: 420)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 12) {
                    PSButton(
                        title: String(localized: String.LocalizationValue("ui.exchange.declineButton")),
                        isProminent: false
                    ) {
                        // 거절하면 내가 이미 보낸 카드도 무의미해지므로, 시퀀스 전체를
                        // 정리하고 다시 카드 선택 화면으로 돌아간다. 상대에게도 알려야
                        // 오지 않을 카드를 계속 기다리지 않는다.
                        service.send(.exchangeReset)
                        resetRound()
                    }
                    PSButton(title: String(localized: String.LocalizationValue("ui.exchange.acceptButton"))) {
                        acceptCard(contender)
                    }
                }
            }
            .padding(20)
        }
    }

    private var savedView: some View {
        VStack(spacing: 20) {
            Text(String(localized: String.LocalizationValue("ui.exchange.savedTitle")))
                .font(PSTypography.pageTitle)
                .foregroundStyle(PSColor.skyStrong)

            if let oppCard {
                ScaledCardArtboard(content: CardArtboardContent(contender: oppCard))
                    .frame(maxWidth: 360)
                    .frame(maxWidth: .infinity)
            }

            PSButton(title: String(localized: String.LocalizationValue("ui.exchange.exchangeAgainButton"))) {
                // 나만 리셋하면 상대는 저장 완료 화면에 그대로 남아 상태가 어긋난다.
                service.send(.exchangeReset)
                resetRound()
            }
            PSButton(
                title: String(localized: String.LocalizationValue("ui.exchange.exitButton")),
                isProminent: false
            ) {
                service.disconnect()
                resetRound()
            }
        }
        .padding(40)
    }

    @ViewBuilder
    private func cardThumbnail(_ card: ScanCard) -> some View {
        if let uiImage = UIImage(data: card.photoData) {
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: 8).fill(PSColor.cardFill)
        }
    }

    private var cancelButton: some View {
        PSButton(
            title: String(localized: String.LocalizationValue("ui.multiBattle.cancel")),
            isProminent: false
        ) {
            service.disconnect()
            resetRound()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - 로직

    private func selectCard(_ card: ScanCard) {
        // 근거리 전송용으로 이미지를 축소해 큰 전송으로 인한 연결 끊김을 줄인다.
        let contender = BattleContender(card: card).networkOptimized()
        myCard = contender
        service.send(.card(contender))
    }

    private func handle(_ message: MultipeerMessage) {
        switch message {
        case .card(let contender):
            oppCard = contender
        case .exchangeReset:
            // 상대가 거절했거나 다시 교환하자고 한 경우. 양쪽이 같이 처음으로 돌아간다.
            resetRound()
        case .result, .rematch:
            break // 배틀 전용 메시지 — 교환 화면에선 무시
        case .ping:
            break // 연결 유지용 — 무시
        }
    }

    private func acceptCard(_ contender: BattleContender) {
        // 받은 시점을 새 스캔 일시로 삼는다 — 방금 새로 생긴 카드처럼.
        let card = ScanCard(
            name: contender.name,
            photoData: contender.imageData,
            power: contender.power,
            typeID: contender.typeID,
            commentID: contender.commentID
        )
        modelContext.insert(card)
        didSave = true
    }

    private func resetRound() {
        myCard = nil
        oppCard = nil
        didSave = false
    }
}
