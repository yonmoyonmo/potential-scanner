//
//  BattleView.swift
//  Potential Scanner
//
//  싱글 배틀: 보관함 카드 2장을 골라 대결. 판정·연출은 BattleRevealView 공유.
//

import SwiftData
import SwiftUI

struct BattleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScanCard.scannedAt, order: .reverse) private var cards: [ScanCard]

    @State private var slotA: ScanCard?
    @State private var slotB: ScanCard?
    @State private var pickingSlot: Slot?
    @State private var active: ActiveBattle?

    private struct ActiveBattle {
        let a: BattleContender
        let b: BattleContender
        let outcome: BattleOutcome
    }

    fileprivate enum Slot: Identifiable {
        case a, b
        var id: Int { self == .a ? 0 : 1 }
    }

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            if let active {
                BattleRevealView(
                    contenderA: active.a,
                    contenderB: active.b,
                    outcome: active.outcome,
                    onRematch: { withAnimation { self.active = nil } },
                    onExit: { dismiss() }
                )
            } else if cards.count < 2 {
                Text(String(localized: String.LocalizationValue("ui.battle.needCards")))
                    .font(PSTypography.body)
                    .foregroundStyle(PSColor.soft)
                    .multilineTextAlignment(.center)
                    .padding(40)
            } else {
                setupView
            }
        }
        .psNavigationTitle("ui.battle.title")
        .sheet(item: $pickingSlot) { slot in
            CardPickerSheet(cards: cards) { picked in
                switch slot {
                case .a: slotA = picked
                case .b: slotB = picked
                }
                pickingSlot = nil
            }
        }
    }

    private var setupView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                slotButton(card: slotA, labelKey: "ui.battle.pickSlotA") { pickingSlot = .a }
                Text(String(localized: String.LocalizationValue("ui.battle.vs")))
                    .font(PSTypography.pageTitle)
                    .foregroundStyle(PSColor.ink)
                slotButton(card: slotB, labelKey: "ui.battle.pickSlotB") { pickingSlot = .b }
            }
            .padding(.horizontal, 20)

            PSButton(title: String(localized: String.LocalizationValue("ui.battle.startButton"))) {
                startBattle()
            }
            .padding(.horizontal, 40)
            .disabled(slotA == nil || slotB == nil || slotA === slotB)
            .opacity(slotA == nil || slotB == nil || slotA === slotB ? 0.4 : 1)
        }
    }

    private func slotButton(card: ScanCard?, labelKey: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let card {
                    ScaledCardArtboard(content: CardArtboardContent(card: card))
                } else {
                    RoundedRectangle(cornerRadius: PSRadius.card)
                        .fill(PSColor.cardFill)
                        .aspectRatio(CardCanvas.aspectRatio, contentMode: .fit)
                        .overlay(
                            Text(String(localized: String.LocalizationValue("ui.battle.pickPrompt")))
                                .font(.caption)
                                .foregroundStyle(PSColor.soft)
                        )
                        .psHardShadow(radius: PSRadius.card)
                }
                Text(String(localized: String.LocalizationValue(labelKey)))
                    .font(.caption)
                    .foregroundStyle(PSColor.soft)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func startBattle() {
        guard let a = slotA, let b = slotB else { return }
        let cA = BattleContender(card: a)
        let cB = BattleContender(card: b)
        let outcome = BattleEngine.resolve(cA, cB)
        BattleRecorder.record(outcome, in: modelContext, myCards: cards)
        active = ActiveBattle(a: cA, b: cB, outcome: outcome)
    }
}

/// 보관함 카드 하나를 고르는 목록 시트. 싱글/멀티 배틀 공용.
struct CardPickerSheet: View {
    let cards: [ScanCard]
    let onPick: (ScanCard) -> Void

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()
            List {
                ForEach(cards) { card in
                    Button {
                        onPick(card)
                    } label: {
                        HStack(spacing: 12) {
                            thumbnail(card)
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
    }

    @ViewBuilder
    private func thumbnail(_ card: ScanCard) -> some View {
        if let uiImage = UIImage(data: card.photoData) {
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: 8).fill(PSColor.cardFill)
        }
    }
}
