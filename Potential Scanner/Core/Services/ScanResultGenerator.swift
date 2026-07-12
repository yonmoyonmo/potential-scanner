//
//  ScanResultGenerator.swift
//  Potential Scanner
//

import UIKit

struct ScanResult {
    let photo: UIImage
    let power: Int
    let type: PotentialType
    let commentID: String
    let closingLineID: String
    let powerBasisID: String
}

enum ScanResultGenerator {
    /// 타입/코멘트는 서로 완전히 독립적으로 랜덤 추출한다 (콘텐츠.md: 의도된 미스매치가 재미 포인트).
    static func generate(from photo: UIImage) -> ScanResult {
        ScanResult(
            photo: photo,
            power: PowerCalculator.power(from: photo),
            type: PotentialType.all.randomElement()!,
            commentID: CommentPool.commentIDs.randomElement()!,
            closingLineID: CommentPool.closingLineIDs.randomElement()!,
            powerBasisID: CommentPool.powerBasisIDs.randomElement()!
        )
    }
}
