//
//  CardListView.swift
//  Potential Scanner
//

import SwiftUI
import SwiftData

struct CardListView: View {
    @Binding var path: NavigationPath

    @Query(sort: \ScanCard.scannedAt, order: .reverse) private var cards: [ScanCard]

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            if cards.isEmpty {
                Text(String(localized: String.LocalizationValue("ui.cardList.empty")))
                    .font(PSTypography.body)
                    .foregroundStyle(PSColor.soft)
            } else {
                List {
                    ForEach(cards) { card in
                        Button {
                            path.append(AppRoute.cardDetail(card))
                        } label: {
                            CardRow(card: card)
                        }
                        .buttonStyle(PressableRowStyle())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .psNavigationTitle("ui.cardList.title")
    }
}

private struct PressableRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct CardRow: View {
    let card: ScanCard

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: PSRadius.card))

            VStack(alignment: .leading, spacing: 4) {
                Text(card.displayName)
                    .font(PSTypography.body)
                    .foregroundStyle(PSColor.ink)
                Text("\(PotentialType.find(byID: card.typeID)?.displayLabel ?? card.typeID) · \(card.power)")
                    .font(.caption)
                    .foregroundStyle(PSColor.soft)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(PSColor.soft)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: PSRadius.card)
                .fill(PSColor.cardFill)
        )
        .psHardShadow(radius: PSRadius.card)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let uiImage = UIImage(data: card.photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: PSRadius.card)
                .fill(PSColor.cardFill)
        }
    }
}
