//
//  BattleEngine.swift
//  Potential Scanner
//
//  배틀 판정. 전투력만 비교하면 재미없으니 은닉 상성(AffinityFamily)을 얹는다.
//  상성 우위면 전투력에 배율을 곱해 비교 — 전투력이 낮아도 상성으로 역전 가능.
//  BattleContender 값 타입 기준이라 싱글/근거리 멀티 배틀 양쪽에서 동일하게 쓴다.
//  (멀티에서는 호스트가 이 함수로 판정한 BattleOutcome을 게스트에 그대로 전송)
//

import Foundation

struct BattleOutcome: Codable {
    let winner: BattleContender
    let loser: BattleContender
    let winnerEffectivePower: Int
    let loserEffectivePower: Int
    /// 승자 발표 문구 (여러 개 중 랜덤).
    let victoryLine: String
    /// 상성/역전/무승부 등 결과를 설명하는 문구. 상성이 아예 무관하면 nil.
    let message: String?
}

enum BattleEngine {
    /// 상성 우위 시 전투력 배율.
    private static let affinityMultiplier = 1.4

    static func resolve(_ a: BattleContender, _ b: BattleContender) -> BattleOutcome {
        let aHasEdge = a.affinityFamily.beats(b.affinityFamily)
        let bHasEdge = b.affinityFamily.beats(a.affinityFamily) // 링 구조상 동시 참 불가

        let effA = Int((Double(a.power) * (aHasEdge ? affinityMultiplier : 1.0)).rounded())
        let effB = Int((Double(b.power) * (bHasEdge ? affinityMultiplier : 1.0)).rounded())

        // 승자 결정 (동률이면 무작위)
        let aWins: Bool
        let isTie: Bool
        if effA != effB {
            aWins = effA > effB
            isTie = false
        } else {
            aWins = Bool.random()
            isTie = true
        }

        let winner = aWins ? a : b
        let loser = aWins ? b : a
        let winnerEff = aWins ? effA : effB
        let loserEff = aWins ? effB : effA
        let edgeHolder: BattleContender? = aHasEdge ? a : (bHasEdge ? b : nil)

        let victoryLine = formatted(pickKey(prefix: "battle.victory", count: 8), winner.name, "")

        let message = messageFor(
            winner: winner,
            loser: loser,
            edgeHolder: edgeHolder,
            isTie: isTie
        )

        return BattleOutcome(
            winner: winner,
            loser: loser,
            winnerEffectivePower: winnerEff,
            loserEffectivePower: loserEff,
            victoryLine: victoryLine,
            message: message
        )
    }

    private static func messageFor(
        winner: BattleContender,
        loser: BattleContender,
        edgeHolder: BattleContender?,
        isTie: Bool
    ) -> String? {
        let winnerName = winner.name
        let loserName = loser.name

        if isTie {
            return formatted(pickKey(prefix: "battle.tie", count: 3), winnerName, loserName)
        }
        guard let edgeHolder else { return nil } // 상성 무관 → 문구 없음

        if edgeHolder.id == winner.id {
            return formatted(pickKey(prefix: "battle.affinityWin", count: 6), winnerName, loserName)
        } else {
            // 상성 열세였던 쪽이 전투력으로 이긴 역전
            return formatted(pickKey(prefix: "battle.affinityUpset", count: 3), winnerName, loserName)
        }
    }

    private static func pickKey(prefix: String, count: Int) -> String {
        String(format: "\(prefix).%03d", Int.random(in: 1...count))
    }

    private static func formatted(_ key: String, _ a: String, _ b: String) -> String {
        String(format: String(localized: String.LocalizationValue(key)), a, b)
    }
}
