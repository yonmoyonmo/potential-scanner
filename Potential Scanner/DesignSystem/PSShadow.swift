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
            // content가 반투명(카드 틴트 등)일 수 있어, 그림자가 그 뒤에서 비쳐 보이지
            // 않도록 불투명 받침을 먼저 깔아 차단한다. 그 다음에야 그림자를 offset만큼
            // 밀어서 더 뒤에 두면, 받침 바깥으로 삐져나온 부분만 그림자로 보인다.
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(PSColor.cloud)
            )
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
