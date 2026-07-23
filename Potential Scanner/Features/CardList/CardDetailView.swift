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
    @State private var saveImageState: SaveImageState = .idle
    @State private var showSaveImageFailed = false

    private enum SaveImageState: Equatable {
        case idle, saving, saved

        var titleKey: String {
            switch self {
            case .idle: "ui.cardDetail.saveImageButton"
            case .saving: "ui.cardDetail.saveImageSaving"
            case .saved: "ui.cardDetail.saveImageSaved"
            }
        }
    }

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    ScaledCardArtboard(content: CardArtboardContent(card: card))
                        .frame(maxWidth: 420)
                        .frame(maxWidth: .infinity)

                    Text(String(
                        format: String(localized: String.LocalizationValue("ui.cardDetail.record")),
                        card.wins, card.losses
                    ))
                    .font(PSTypography.body)
                    .foregroundStyle(PSColor.soft)

                    PSButton(
                        title: String(localized: String.LocalizationValue(saveImageState.titleKey)),
                        isProminent: true
                    ) {
                        saveImage()
                    }
                    .disabled(saveImageState != .idle)

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
        .psConfirmModal(
            isPresented: $showSaveImageFailed,
            title: String(localized: String.LocalizationValue("ui.cardDetail.saveImageFailedTitle")),
            message: String(localized: String.LocalizationValue("ui.cardDetail.saveImageFailedMessage")),
            confirmTitle: String(localized: String.LocalizationValue("ui.cardDetail.saveImageOpenSettings"))
        ) {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }

    private func saveImage() {
        saveImageState = .saving
        Task {
            guard let image = CardImageSaver.renderImage(content: CardArtboardContent(card: card)) else {
                saveImageState = .idle
                showSaveImageFailed = true
                return
            }
            do {
                try await CardImageSaver.save(image)
                saveImageState = .saved
                try? await Task.sleep(for: .seconds(1.5))
                saveImageState = .idle
            } catch {
                saveImageState = .idle
                showSaveImageFailed = true
            }
        }
    }
}
