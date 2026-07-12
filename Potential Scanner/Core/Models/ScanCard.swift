//
//  ScanCard.swift
//  Potential Scanner
//

import Foundation
import SwiftData

@Model
final class ScanCard {
    var id: UUID
    var photoData: Data
    var power: Int
    var typeID: String
    var commentID: String
    var closingLineID: String
    var scannedAt: Date

    init(
        photoData: Data,
        power: Int,
        typeID: String,
        commentID: String,
        closingLineID: String,
        scannedAt: Date = .now
    ) {
        self.id = UUID()
        self.photoData = photoData
        self.power = power
        self.typeID = typeID
        self.commentID = commentID
        self.closingLineID = closingLineID
        self.scannedAt = scannedAt
    }
}
