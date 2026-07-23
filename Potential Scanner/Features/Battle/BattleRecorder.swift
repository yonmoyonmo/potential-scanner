//
//  BattleRecorder.swift
//  Potential Scanner
//
//  배틀 결과를 전적으로 저장하고, 내 DB에 있는 카드의 승/패를 갱신한다.
//  멀티 배틀 상대 카드는 내 DB에 없으므로(id 불일치) 자연히 내 카드만 갱신된다.
//

import Foundation
import SwiftData

enum BattleRecorder {
    static func record(_ outcome: BattleOutcome, in context: ModelContext, myCards: [ScanCard]) {
        context.insert(BattleRecord(outcomeData: BattleOutcomeCoder.encode(outcome)))
        if let winnerCard = myCards.first(where: { $0.id == outcome.winner.id }) {
            winnerCard.wins += 1
        }
        if let loserCard = myCards.first(where: { $0.id == outcome.loser.id }) {
            loserCard.losses += 1
        }
    }
}
