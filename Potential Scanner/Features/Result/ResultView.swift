//
//  ResultView.swift
//  Potential Scanner
//

import SwiftUI
import SwiftData

struct ResultView: View {
    let result: ScanResult
    var onSaved: () -> Void
    var onCancel: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var isSaved = false
    @State private var cardName = ""
    @State private var showNamePrompt = false
    @State private var showDiscardConfirm = false

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    ScaledCardArtboard(content: CardArtboardContent(result: result, name: cardName))
                        .frame(maxWidth: 420)
                        .frame(maxWidth: .infinity)

                    Text(CommentPool.text(forID: result.powerBasisID))
                        .font(.caption)
                        .foregroundStyle(PSColor.soft)

                    Text(CommentPool.text(forID: result.closingLineID))
                        .font(.caption)
                        .foregroundStyle(PSColor.soft)

                    PSButton(
                        title: String(localized: String.LocalizationValue(
                            isSaved ? "ui.result.savedToast" : "ui.result.saveButton"
                        )),
                        isProminent: !isSaved
                    ) {
                        showNamePrompt = true
                    }
                    .disabled(isSaved)

                    if !isSaved {
                        PSButton(
                            title: String(localized: String.LocalizationValue("ui.result.discardButton")),
                            isProminent: false
                        ) {
                            showDiscardConfirm = true
                        }
                    }
                }
                .padding(20)
            }
        }
        .psTextPromptModal(
            isPresented: $showNamePrompt,
            text: $cardName,
            title: String(localized: String.LocalizationValue("ui.result.namePromptTitle")),
            placeholder: String(localized: String.LocalizationValue("ui.result.namePlaceholder")),
            confirmTitle: String(localized: String.LocalizationValue("ui.cardList.renameSave"))
        ) {
            save()
        }
        .psConfirmModal(
            isPresented: $showDiscardConfirm,
            title: String(localized: String.LocalizationValue("ui.confirm.discardTitle")),
            message: String(localized: String.LocalizationValue("ui.confirm.discardMessage")),
            confirmTitle: String(localized: String.LocalizationValue("ui.confirm.discardConfirm"))
        ) {
            onCancel()
        }
    }

    private func save() {
        guard !isSaved else { return }
        let downscaled = result.photo.downscaled(maxDimension: 1200)
        let photoData = downscaled.jpegData(compressionQuality: 0.85) ?? result.photo.jpegData(compressionQuality: 0.85)
        guard let photoData else { return }
        let card = ScanCard(
            name: cardName.trimmingCharacters(in: .whitespacesAndNewlines),
            photoData: photoData,
            power: result.power,
            typeID: result.type.id,
            commentID: result.commentID
        )
        modelContext.insert(card)
        isSaved = true
        onSaved()
    }
}
