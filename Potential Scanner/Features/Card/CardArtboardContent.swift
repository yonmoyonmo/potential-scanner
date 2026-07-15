//
//  CardArtboardContent.swift
//  Potential Scanner
//
//  ScanResult(저장 전)와 ScanCard(저장 후) 양쪽 모두 이 형태로 변환해서
//  같은 CardArtboardView에 넘긴다 — 카드 비주얼은 한 곳에서만 관리.
//

import UIKit

struct CardArtboardContent {
    let photo: UIImage
    let displayName: String
    let power: Int
    let typeLabel: String
    let typeDescription: String
    let comment: String
    let dateText: String

    /// 전투력(1~999,999)을 100,000 단위로 쪼개 최대 10개의 별로 환산.
    var starCount: Int {
        min(10, max(1, Int(ceil(Double(power) / 100_000))))
    }
}

extension CardArtboardContent {
    init(result: ScanResult, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(
            photo: result.photo,
            displayName: trimmed.isEmpty ? result.type.name : trimmed,
            power: result.power,
            typeLabel: result.type.displayLabel,
            typeDescription: result.type.description,
            comment: CommentPool.text(forID: result.commentID),
            dateText: Date.now.formatted(date: .abbreviated, time: .shortened)
        )
    }

    init(card: ScanCard) {
        let type = PotentialType.find(byID: card.typeID)
        self.init(
            photo: UIImage(data: card.photoData) ?? UIImage(),
            displayName: card.displayName,
            power: card.power,
            typeLabel: type?.displayLabel ?? card.typeID,
            typeDescription: type?.description ?? "",
            comment: CommentPool.text(forID: card.commentID),
            dateText: card.scannedAt.formatted(date: .abbreviated, time: .shortened)
        )
    }
}
