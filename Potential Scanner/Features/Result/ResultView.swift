//
//  ResultView.swift
//  Potential Scanner
//

import SwiftUI
import SwiftData

struct ResultView: View {
    let result: ScanResult
    var onSaved: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var isSaved = false

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Image(uiImage: result.photo)
                        .resizable()
                        .scaledToFill()
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
                                Text("\(result.power)")
                                    .font(PSTypography.pageTitle)
                                    .foregroundStyle(PSColor.ink)
                            }
                            Text(CommentPool.text(forID: result.powerBasisID))
                                .font(.caption)
                                .foregroundStyle(PSColor.soft)

                            Divider().background(PSColor.divider)

                            Text(result.type.name)
                                .font(PSTypography.pageTitle)
                                .foregroundStyle(PSColor.skyStrong)
                            Text(result.type.description)
                                .font(PSTypography.body)
                                .foregroundStyle(PSColor.muted)

                            Divider().background(PSColor.divider)

                            Text(CommentPool.text(forID: result.commentID))
                                .font(PSTypography.body)
                                .foregroundStyle(PSColor.ink)

                            Text(CommentPool.text(forID: result.closingLineID))
                                .font(.caption)
                                .foregroundStyle(PSColor.soft)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    PSButton(
                        title: String(localized: String.LocalizationValue(
                            isSaved ? "ui.result.savedToast" : "ui.result.saveButton"
                        )),
                        isProminent: !isSaved
                    ) {
                        save()
                    }
                    .disabled(isSaved)
                }
                .padding(20)
            }
        }
    }

    private func save() {
        guard !isSaved, let photoData = result.photo.jpegData(compressionQuality: 0.85) else { return }
        let card = ScanCard(
            photoData: photoData,
            power: result.power,
            typeID: result.type.id,
            commentID: result.commentID,
            closingLineID: result.closingLineID
        )
        modelContext.insert(card)
        isSaved = true
        onSaved()
    }
}
