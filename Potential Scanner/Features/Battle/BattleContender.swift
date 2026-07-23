//
//  BattleContender.swift
//  Potential Scanner
//
//  배틀에 출전하는 카드의 값 타입. 내 SwiftData 카드(ScanCard)든 근거리 배틀로
//  상대에게서 받은 카드든 동일하게 다루기 위한 Codable 표현 — 멀티 배틀에서
//  이 구조체를 그대로 기기 간에 주고받는다.
//

import UIKit

struct BattleContender: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String
    let power: Int
    let typeID: String
    let commentID: String
    let imageData: Data
    let scannedAt: Date
}

extension BattleContender {
    init(card: ScanCard) {
        self.init(
            id: card.id,
            name: card.displayName,
            power: card.power,
            typeID: card.typeID,
            commentID: card.commentID,
            imageData: card.photoData,
            scannedAt: card.scannedAt
        )
    }

    var affinityFamily: AffinityFamily {
        AffinityFamily.family(forTypeID: typeID)
    }

    /// 근거리 전송용으로 이미지를 작게 줄인 사본. 배틀 표시엔 충분하고 전송은 가벼워진다.
    func networkOptimized() -> BattleContender {
        guard let image = UIImage(data: imageData) else { return self }
        let small = image.downscaled(maxDimension: 600)
        let data = small.jpegData(compressionQuality: 0.7) ?? imageData
        return BattleContender(
            id: id, name: name, power: power, typeID: typeID,
            commentID: commentID, imageData: data, scannedAt: scannedAt
        )
    }
}

extension CardArtboardContent {
    init(contender: BattleContender) {
        let type = PotentialType.find(byID: contender.typeID)
        self.init(
            photo: UIImage(data: contender.imageData) ?? UIImage(),
            displayName: contender.name,
            power: contender.power,
            typeLabel: type?.displayLabel ?? contender.typeID,
            typeDescription: type?.description ?? "",
            comment: CommentPool.text(forID: contender.commentID),
            dateText: contender.scannedAt.formatted(date: .abbreviated, time: .shortened)
        )
    }
}
