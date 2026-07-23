//
//  AppRoute.swift
//  Potential Scanner
//

import Foundation

enum AppRoute: Hashable {
    case scan
    case result(ScanResultToken)
    case cardList
    case cardDetail(ScanCard)
    case battle
    case multiplayerBattle
    case history
    case battleRecord(BattleRecord)
}

/// NavigationPath에 넣을 수 있도록 ScanResult를 감싸는 Hashable 토큰.
/// (ScanResult 자체는 UIImage를 들고 있어 값 비교보다 참조 동일성으로 다룬다)
final class ScanResultToken: Hashable {
    let result: ScanResult

    init(_ result: ScanResult) {
        self.result = result
    }

    static func == (lhs: ScanResultToken, rhs: ScanResultToken) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
