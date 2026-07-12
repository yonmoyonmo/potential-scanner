//
//  PSColor.swift
//  Potential Scanner
//
//  Design Essence 팔레트 (yowenomo.studio site.css 원본 값 그대로)
//

import SwiftUI

enum PSColor {
    static let skyStrong = Color(hex: 0x0563FA)
    static let grassMid = Color(hex: 0x3A8402)
    static let hill = Color(hex: 0x579C02)
    static let cloud = Color(hex: 0xEAF3FC)
    static let ink = Color(hex: 0x111418)
    static let muted = Color(hex: 0x354047)
    static let soft = Color(hex: 0x4A5557)
    static let shadowDeep = Color(hex: 0x192B1E)
    static let hairBrown = Color(hex: 0x4A2D2A)
    static let divider = Color(hex: 0x111418).opacity(0.16)
    static let cardFill = Color.white.opacity(0.5)

    static let background = LinearGradient(
        colors: [hill, cloud, skyStrong],
        startPoint: .bottom,
        endPoint: .top
    )
}

private extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
