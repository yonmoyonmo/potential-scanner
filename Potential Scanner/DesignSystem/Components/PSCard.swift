//
//  PSCard.swift
//  Potential Scanner
//

import SwiftUI

struct PSCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: PSRadius.card)
                    .fill(PSColor.cardFill)
            )
            .psHardShadow(radius: PSRadius.card)
    }
}
