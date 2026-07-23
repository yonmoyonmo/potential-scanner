//
//  MultiplayerBattleView.swift
//  Potential Scanner
//
//  근거리 멀티 배틀. 역할 선택(호스트/참가) → 연결 → 카드 교환 → 호스트 단독 판정
//  → 결과 동기화. 호스트가 BattleEngine으로 판정한 outcome을 게스트에 그대로 전송한다.
//

import MultipeerConnectivity
import SwiftData
import SwiftUI

struct MultiplayerBattleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScanCard.scannedAt, order: .reverse) private var cards: [ScanCard]
    @State private var service = MultipeerService()

    // 연결 이후 라운드 상태
    @State private var myCard: BattleContender?
    @State private var oppCard: BattleContender?
    @State private var outcome: BattleOutcome?

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            // 결과가 나온 뒤엔 연결 상태와 무관하게 배틀 화면을 유지한다.
            // (리빌 시점엔 양쪽 다 이미 outcome을 가지고 있어 연결이 끊겨도 문제없음 —
            //  배틀 애니메이션 동안 링크가 idle로 끊겨 튕기던 문제를 막는다.)
            if let outcome, let myCard, let oppCard {
                BattleRevealView(
                    contenderA: myCard,
                    contenderB: oppCard,
                    outcome: outcome,
                    onRematch: { sendRematch() },
                    onExit: {
                        service.disconnect()
                        resetRound()
                        dismiss()
                    }
                )
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
        .psNavigationTitle("ui.multiBattle.title")
        .onAppear {
            service.onReceiveMessage = handle
        }
        // onDisappear로 disconnect하지 않는다 — NavigationStack 안에서 리스트를
        // 조작할 때 onDisappear가 튀어 연결이 끊기는 문제가 있었다. 정리는 취소/종료
        // 버튼과 서비스 deinit(뷰 해제 시점)에서 처리한다.
    }

    // MARK: - 역할 선택 / 연결 단계

    private var roleSelect: some View {
        VStack(spacing: 16) {
            PSButton(title: String(localized: String.LocalizationValue("ui.multiBattle.hostButton"))) {
                service.hostBattle()
            }
            PSButton(
                title: String(localized: String.LocalizationValue("ui.multiBattle.joinButton")),
                isProminent: false
            ) {
                service.joinBattle()
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

    // MARK: - 연결됨: 카드 교환 → 판정 → 결과

    // 결과가 나온 뒤(outcome != nil)의 리빌은 body 상단에서 처리한다.
    // 여기선 아직 결과 전인 카드 선택/대기만 담당.
    @ViewBuilder
    private var connectedView: some View {
        if myCard != nil {
            statusView(messageKey: "ui.multiBattle.waitingOpponent")
        } else {
            pickPromptView
        }
    }

    // 카드 선택은 시트 대신 인라인 목록으로 — NavigationStack 안에서 시트를 띄우면
    // 부모 뷰 onDisappear가 튀어 연결이 끊기는 문제가 있어 화면 내에서 바로 고르게 한다.
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

            Text(String(localized: String.LocalizationValue("ui.multiBattle.pickYourCard")))
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

    // MARK: - 라운드 로직

    private func selectCard(_ card: ScanCard) {
        // 근거리 전송용으로 이미지를 축소해 큰 전송으로 인한 연결 끊김을 줄인다.
        let contender = BattleContender(card: card).networkOptimized()
        myCard = contender
        service.send(.card(contender))
        resolveIfHostReady()
    }

    private func handle(_ message: MultipeerMessage) {
        switch message {
        case .card(let contender):
            oppCard = contender
            resolveIfHostReady()
        case .result(let received):
            // 게스트: 호스트가 판정한 결과를 그대로 사용 (중복 저장 방지)
            guard outcome == nil else { return }
            outcome = received
            BattleRecorder.record(received, in: modelContext, myCards: cards)
        case .rematch:
            resetRound()
        case .ping:
            break // 연결 유지용 — 무시
        }
    }

    /// 호스트만 판정한다. 내 카드와 상대 카드가 모두 도착하면 결과를 계산해 전송.
    private func resolveIfHostReady() {
        guard service.isHost, outcome == nil, let mine = myCard, let opp = oppCard else { return }
        let result = BattleEngine.resolve(mine, opp)
        outcome = result
        service.send(.result(result))
        BattleRecorder.record(result, in: modelContext, myCards: cards)
    }

    private func sendRematch() {
        service.send(.rematch)
        resetRound()
    }

    private func resetRound() {
        myCard = nil
        oppCard = nil
        outcome = nil
    }
}
