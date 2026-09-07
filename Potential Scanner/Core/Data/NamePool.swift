//
//  NamePool.swift
//  Potential Scanner
//
//  이름을 안 붙인 카드에 붙는 기본 이름 풀. 예전엔 타입 이름을 그대로 재활용했는데,
//  타입/이름은 서로 완전히 독립적인 텍스트 콘텐츠로 분리한다.
//

import Foundation

enum NamePool {
    /// 기본 이름 id: name.001 ... name.024
    static let nameIDs: [String] = (1...24).map { String(format: "name.%03d", $0) }

    static func text(forID id: String) -> String {
        String(localized: String.LocalizationValue(id))
    }
}
