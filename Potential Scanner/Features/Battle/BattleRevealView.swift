//
//  BattleRevealView.swift
//  Potential Scanner
//
//  대결 연출 + 결과. 이미 판정된 BattleOutcome을 받아 오도미터 리빌 → 클래시 →
//  승자 공개 순으로 보여준다. 싱글 배틀과 근거리 멀티 배틀이 공유한다.
//  (멀티에서는 호스트가 판정한 outcome을 게스트도 그대로 받아 같은 화면을 본다)
//

import SwiftUI

struct BattleRevealView: View {
    let contenderA: BattleContender
    let contenderB: BattleContender
    let outcome: BattleOutcome
    var onRematch: () -> Void
    var onExit: (() -> Void)?

    @State private var stage: Stage = .revealing
    @State private var clashTrigger = 0
    @State private var rollTick = 0
    @State private var tensionPulse = 0
    @State private var tensionScale: CGFloat = 1
    @State private var displayedPowerA = 0
    @State private var displayedPowerB = 0
    @State private var clashFlash = false

    private enum Stage { case revealing, result }

    var body: some View {
        ZStack {
            switch stage {
            case .revealing:
                VStack {
                    Spacer()
                    arena(showPowers: true, decided: false)
                        .scaleEffect(tensionScale)
                    Spacer()
                }
            case .result:
                resultView
            }

            Color.white
                .opacity(clashFlash ? 1 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: clashTrigger)
        .sensoryFeedback(.selection, trigger: rollTick)
        .sensoryFeedback(.impact(weight: .medium), trigger: tensionPulse)
        .task { await runReveal() }
    }

    private func arena(showPowers: Bool, decided: Bool) -> some View {
        HStack(spacing: 12) {
            battleCard(contenderA, isWinner: outcome.winner.id == contenderA.id, decided: decided,
                       power: showPowers ? displayedPowerA : nil)
            battleCard(contenderB, isWinner: outcome.winner.id == contenderB.id, decided: decided,
                       power: showPowers ? displayedPowerB : nil)
        }
        .padding(.horizontal, 16)
    }

    private func battleCard(_ contender: BattleContender, isWinner: Bool, decided: Bool, power: Int?) -> some View {
        ScaledCardArtboard(content: CardArtboardContent(contender: contender))
            .saturation(decided && !isWinner ? 0 : 1)
            .opacity(decided && !isWinner ? 0.5 : 1)
            .overlay {
                if decided && isWinner {
                    RoundedRectangle(cornerRadius: PSRadius.card)
                        .stroke(PSColor.signalAmber, lineWidth: 5)
                        .shadow(color: PSColor.signalAmber, radius: 12)
                }
            }
            .overlay(alignment: .bottom) {
                if let power {
                    Text(power.formatted(.number.grouping(.automatic)))
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.black.opacity(0.75)))
                        .offset(y: 14)
                }
            }
            .scaleEffect(decided && isWinner ? 1.05 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: decided)
    }

    private var resultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                arena(showPowers: true, decided: true)
                    .padding(.bottom, 28)

                if let message = outcome.message {
                    Text(message)
                        .font(PSTypography.summary)
                        .foregroundStyle(PSColor.ink)
                        .multilineTextAlignment(.center)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: PSRadius.card).fill(PSColor.cardFill))
                        .psHardShadow(radius: PSRadius.card)
                }

                Text(outcome.victoryLine)
                    .font(PSTypography.pageTitle)
                    .foregroundStyle(PSColor.skyStrong)
                    .multilineTextAlignment(.center)

                PSButton(title: String(localized: String.LocalizationValue("ui.battle.rematchButton"))) {
                    onRematch()
                }

                if let onExit {
                    PSButton(
                        title: String(localized: String.LocalizationValue("ui.battle.exitButton")),
                        isProminent: false
                    ) {
                        onExit()
                    }
                }
            }
            .padding(20)
        }
    }

    private func runReveal() async {
        let effA = effectivePower(of: contenderA)
        let effB = effectivePower(of: contenderB)
        displayedPowerA = 0
        displayedPowerB = 0

        // 1) 전투력 오도미터: 숫자를 빠르게 굴리다가 점점 느려지며 실제값에 착지.
        let steps = 40
        for i in 0..<steps {
            displayedPowerA = Int.random(in: 1...999_999)
            displayedPowerB = Int.random(in: 1...999_999)
            rollTick += 1
            let t = Double(i) / Double(steps)
            try? await Task.sleep(for: .milliseconds(Int(30 + t * t * 210)))
        }
        withAnimation(.snappy(duration: 0.25)) {
            displayedPowerA = effA
            displayedPowerB = effB
        }

        // 2) 숨고르기: 결과 직전 카드를 두근두근 맥동시키며 긴장을 쌓는다(중간 햅틱).
        try? await Task.sleep(for: .milliseconds(500))
        for _ in 0..<3 {
            tensionPulse += 1
            withAnimation(.easeInOut(duration: 0.18)) { tensionScale = 1.05 }
            try? await Task.sleep(for: .milliseconds(230))
            withAnimation(.easeInOut(duration: 0.18)) { tensionScale = 1.0 }
            try? await Task.sleep(for: .milliseconds(230))
        }

        // 3) 클래시: 화면 플래시 + 강한 햅틱, 그 뒤 승자 공개.
        clashTrigger += 1
        withAnimation(.linear(duration: 0.05)) { clashFlash = true }
        try? await Task.sleep(for: .milliseconds(90))
        withAnimation(.easeOut(duration: 0.35)) {
            clashFlash = false
            stage = .result
        }
    }

    private func effectivePower(of contender: BattleContender) -> Int {
        contender.id == outcome.winner.id ? outcome.winnerEffectivePower : outcome.loserEffectivePower
    }
}
