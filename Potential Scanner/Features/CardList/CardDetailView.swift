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
    @State private var showRenamePrompt = false
    @State private var renameText = ""
    @State private var showDeleteConfirm = false

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
                            Text(card.displayName)
                                .font(PSTypography.heroTitle)
                                .foregroundStyle(PSColor.ink)

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

                            Text(type?.displayLabel ?? card.typeID)
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
                        title: String(localized: String.LocalizationValue("ui.cardDetail.renameButton")),
                        isProminent: false
                    ) {
                        renameText = card.name
                        showRenamePrompt = true
                    }

                    PSButton(
                        title: String(localized: String.LocalizationValue("ui.cardDetail.deleteButton")),
                        isProminent: false
                    ) {
                        showDeleteConfirm = true
                    }
                }
                .padding(20)
            }
        }
        .psNavigationTitle("ui.cardDetail.title")
        .psTextPromptModal(
            isPresented: $showRenamePrompt,
            text: $renameText,
            title: String(localized: String.LocalizationValue("ui.cardList.renameAlertTitle")),
            placeholder: String(localized: String.LocalizationValue("ui.result.namePlaceholder")),
            confirmTitle: String(localized: String.LocalizationValue("ui.cardList.renameSave"))
        ) {
            card.name = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        .psConfirmModal(
            isPresented: $showDeleteConfirm,
            title: String(localized: String.LocalizationValue("ui.confirm.deleteTitle")),
            message: String(localized: String.LocalizationValue("ui.confirm.deleteMessage")),
            confirmTitle: String(localized: String.LocalizationValue("ui.confirm.deleteConfirm"))
        ) {
            modelContext.delete(card)
            onDeleted()
        }
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
