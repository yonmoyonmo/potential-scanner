//
//  CommentPool.swift
//  Potential Scanner
//
//  콘텐츠.md "3. 공용 코멘트 풀"(67개), "4. 랜덤 클로징 멘트"(4개),
//  "2. 전투력의 근거" 문구(10개)를 그대로 옮김. 타입과 완전히 독립적으로 랜덤 추출한다.
//

import Foundation

enum CommentPool {
    /// 코멘트 id: comment.001 ... comment.067
    static let commentIDs: [String] = (1...67).map { String(format: "comment.%03d", $0) }

    /// 클로징 멘트 id: closing.001 ... closing.004
    static let closingLineIDs: [String] = (1...4).map { String(format: "closing.%03d", $0) }

    /// 전투력 산출 근거 문구 id: powerBasis.001 ... powerBasis.010
    static let powerBasisIDs: [String] = (1...10).map { String(format: "powerBasis.%03d", $0) }

    /// 스캔 중 로딩 문구 id: loading.001 ... loading.006
    static let loadingLineIDs: [String] = (1...6).map { String(format: "loading.%03d", $0) }

    static func text(forID id: String) -> String {
        String(localized: String.LocalizationValue(id))
    }
}
