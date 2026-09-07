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
    var defaultNameID: String = "name.001"
    var scannedAt: Date
    var wins: Int = 0
    var losses: Int = 0

    init(
        name: String,
        photoData: Data,
        power: Int,
        typeID: String,
        commentID: String,
        defaultNameID: String = "name.001",
        scannedAt: Date = .now
    ) {
        self.id = UUID()
        self.name = name
        self.photoData = photoData
        self.power = power
        self.typeID = typeID
        self.commentID = commentID
        self.defaultNameID = defaultNameID
        self.scannedAt = scannedAt
    }
}

extension ScanCard {
    /// 이름을 안 붙였으면 기본 이름 풀에서 뽑힌 이름으로 대체해서 보여준다.
    var displayName: String {
        name.isEmpty ? NamePool.text(forID: defaultNameID) : name
    }
}
