//
//  BattleRecord.swift
//  Potential Scanner
//
//  배틀 전적 한 건. 멀티 배틀 상대 카드는 내 DB에 없으므로, 판정 결과(BattleOutcome)를
//  스냅샷째로 인코딩해 저장한다 — 나중에 목록/상세/이미지로 다시 꺼내 쓸 수 있다.
//

import Foundation
import SwiftData

@Model
final class BattleRecord {
    var id: UUID
    var date: Date
    /// 인코딩된 BattleOutcome (두 카드 스냅샷 + 승자 + 전투력 + 문구 포함).
    var outcomeData: Data

    init(outcomeData: Data, date: Date = .now) {
        self.id = UUID()
        self.date = date
        self.outcomeData = outcomeData
    }
}

/// BattleOutcome의 Codable 합성 적합성이 MainActor 격리라, nonisolated인 @Model 안에서
/// 직접 인/디코딩하면 경고가 난다. 인/디코딩은 MainActor인 이 헬퍼로 모아서 처리한다.
enum BattleOutcomeCoder {
    static func encode(_ outcome: BattleOutcome) -> Data {
        (try? JSONEncoder().encode(outcome)) ?? Data()
    }

    static func decode(_ data: Data) -> BattleOutcome? {
        try? JSONDecoder().decode(BattleOutcome.self, from: data)
    }
}
