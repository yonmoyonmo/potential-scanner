//
//  CardDetailView.swift
//  Potential Scanner
//

import SwiftUI
import SwiftData

struct CardDetailView: View {
    let card: ScanCard
    var onDeleted: () -> Void

    @Environment(\.modelContext) private var modelContext

    private var type: PotentialType? { PotentialType.find(byID: card.typeID) }

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    photo
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: PSRadius.card))
                        .psHardShadow(radius: PSRadius.card)

                    PSCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(String(localized: String.LocalizationValue("ui.result.powerLabel")))
                                    .font(PSTypography.body)
                                    .foregroundStyle(PSColor.soft)
                                Spacer()
                                Text("\(card.power)")
                                    .font(PSTypography.pageTitle)
                                    .foregroundStyle(PSColor.ink)
                            }

                            Divider().background(PSColor.divider)

                            Text(type?.name ?? card.typeID)
                                .font(PSTypography.pageTitle)
                                .foregroundStyle(PSColor.skyStrong)
                            if let type {
                                Text(type.description)
                                    .font(PSTypography.body)
                                    .foregroundStyle(PSColor.muted)
                            }

                            Divider().background(PSColor.divider)

                            Text(CommentPool.text(forID: card.commentID))
                                .font(PSTypography.body)
                                .foregroundStyle(PSColor.ink)

                            Text(card.scannedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(PSColor.soft)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    PSButton(
                        title: String(localized: String.LocalizationValue("ui.cardDetail.deleteButton")),
                        isProminent: false
                    ) {
                        modelContext.delete(card)
                        onDeleted()
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(String(localized: String.LocalizationValue("ui.cardDetail.title")))
    }

    @ViewBuilder
    private var photo: some View {
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
