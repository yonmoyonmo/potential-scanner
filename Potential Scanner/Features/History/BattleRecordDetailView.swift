//
//  BattleRecordDetailView.swift
//  Potential Scanner
//

import SwiftData
import SwiftUI

struct BattleRecordDetailView: View {
    let record: BattleRecord
    var onDeleted: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var resultImage: UIImage?
    @State private var saveState: SaveState = .idle
    @State private var showSaveFailed = false
    @State private var showDeleteConfirm = false

    private enum SaveState: Equatable {
        case idle, saving, saved
        var titleKey: String {
            switch self {
            case .idle: "ui.history.saveImageButton"
            case .saving: "ui.history.saveImageSaving"
            case .saved: "ui.history.saveImageSaved"
            }
        }
    }

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    if let resultImage {
                        // 화면 미리보기와 저장 이미지가 완전히 같도록, 렌더한 이미지를 그대로 보여준다.
                        Image(uiImage: resultImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: PSRadius.card))

                        PSButton(
                            title: String(localized: String.LocalizationValue(saveState.titleKey)),
                            isProminent: true
                        ) {
                            saveImage()
                        }
                        .disabled(saveState != .idle)
                    } else {
                        ProgressView()
                    }

                    PSButton(
                        title: String(localized: String.LocalizationValue("ui.history.deleteButton")),
                        isProminent: false
                    ) {
                        showDeleteConfirm = true
                    }
                }
                .padding(20)
            }
        }
        .psNavigationTitle("ui.history.detailTitle")
        .task {
            guard resultImage == nil, let outcome = BattleOutcomeCoder.decode(record.outcomeData) else { return }
            resultImage = CardImageSaver.renderImage(BattleResultArtboardView(outcome: outcome), scale: 2)
        }
        .psConfirmModal(
            isPresented: $showDeleteConfirm,
            title: String(localized: String.LocalizationValue("ui.confirm.deleteTitle")),
            message: String(localized: String.LocalizationValue("ui.confirm.deleteMessage")),
            confirmTitle: String(localized: String.LocalizationValue("ui.confirm.deleteConfirm"))
        ) {
            modelContext.delete(record)
            onDeleted()
        }
        .psConfirmModal(
            isPresented: $showSaveFailed,
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
        guard let image = resultImage else { return }
        saveState = .saving
        Task {
            do {
                try await CardImageSaver.save(image)
                saveState = .saved
                try? await Task.sleep(for: .seconds(1.5))
                saveState = .idle
            } catch {
                saveState = .idle
                showSaveFailed = true
            }
        }
    }
}
