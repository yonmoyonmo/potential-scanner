//
//  CardListView.swift
//  Potential Scanner
//

import SwiftUI
import SwiftData

struct CardListView: View {
    @Binding var path: NavigationPath

    @Environment(\.modelContext) private var modelContext
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
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: delete)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .navigationTitle(String(localized: String.LocalizationValue("ui.cardList.title")))
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(cards[index])
        }
    }
}

private struct CardRow: View {
    let card: ScanCard

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: PSRadius.card))

            VStack(alignment: .leading, spacing: 4) {
                Text(PotentialType.find(byID: card.typeID)?.name ?? card.typeID)
                    .font(PSTypography.body)
                    .foregroundStyle(PSColor.ink)
                Text("\(card.power)")
                    .font(.caption)
                    .foregroundStyle(PSColor.soft)
            }

            Spacer()
        }
        .padding(.vertical, 4)
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
