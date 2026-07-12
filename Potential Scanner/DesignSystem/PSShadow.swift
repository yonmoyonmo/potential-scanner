//
//  PSShadow.swift
//  Potential Scanner
//
//  시그니처 하드섀도우: 블러 없는 우하단 45도 섀도우.
//

import SwiftUI

struct PSHardShadow: ViewModifier {
    var radius: CGFloat = 12
    var offset: CGFloat = 6

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(PSColor.shadowDeep.opacity(0.16))
                    .offset(x: offset, y: offset)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(PSColor.shadowDeep.opacity(0.14), lineWidth: 1)
            )
    }
}

extension View {
    func psHardShadow(radius: CGFloat = 12, offset: CGFloat = 6) -> some View {
        modifier(PSHardShadow(radius: radius, offset: offset))
    }
}

enum PSRadius {
    static let card: CGFloat = 12
    static let icon: CGFloat = 18
    static let pill: CGFloat = 999
}
