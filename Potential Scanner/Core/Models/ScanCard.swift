//
//  ScanCard.swift
//  Potential Scanner
//

import Foundation
import SwiftData

@Model
final class ScanCard {
    var id: UUID
    var name: String = ""
    var photoData: Data
    var power: Int
    var typeID: String
    var commentID: String
    var scannedAt: Date
    var wins: Int = 0
    var losses: Int = 0

    init(
        name: String,
        photoData: Data,
        power: Int,
        typeID: String,
        commentID: String,
        scannedAt: Date = .now
    ) {
        self.id = UUID()
        self.name = name
        self.photoData = photoData
        self.power = power
        self.typeID = typeID
        self.commentID = commentID
        self.scannedAt = scannedAt
    }
}

extension ScanCard {
    /// 이름을 안 붙였으면 타입명으로 대체해서 보여준다.
    var displayName: String {
        name.isEmpty ? (PotentialType.find(byID: typeID)?.name ?? typeID) : name
    }
}
