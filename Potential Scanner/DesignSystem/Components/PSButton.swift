//
//  PSButton.swift
//  Potential Scanner
//

import SwiftUI

struct PSButton: View {
    let title: String
    var isProminent: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(PSTypography.summary)
                .foregroundStyle(isProminent ? .white : PSColor.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: PSRadius.card)
                        .fill(isProminent ? PSColor.skyStrong : PSColor.cardFill)
                )
        }
        .buttonStyle(.plain)
        .psHardShadow(radius: PSRadius.card)
    }
}
