//
//  BattleHistoryView.swift
//  Potential Scanner
//

import SwiftData
import SwiftUI

struct BattleHistoryView: View {
    @Binding var path: NavigationPath
    @Query(sort: \BattleRecord.date, order: .reverse) private var records: [BattleRecord]

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            if records.isEmpty {
                Text(String(localized: String.LocalizationValue("ui.history.empty")))
                    .font(PSTypography.body)
                    .foregroundStyle(PSColor.soft)
            } else {
                List {
                    ForEach(records) { record in
                        if let outcome = BattleOutcomeCoder.decode(record.outcomeData) {
                            Button {
                                path.append(AppRoute.battleRecord(record))
                            } label: {
                                RecordRow(outcome: outcome, date: record.date)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .psNavigationTitle("ui.history.title")
    }
}

private struct RecordRow: View {
    let outcome: BattleOutcome
    let date: Date

    var body: some View {
        HStack(spacing: 10) {
            thumbnail(outcome.winner)
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(PSColor.signalAmber, lineWidth: 2))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(outcome.winner.name)  \(String(localized: String.LocalizationValue("ui.history.vs")))  \(outcome.loser.name)")
                    .font(PSTypography.body)
                    .foregroundStyle(PSColor.ink)
                    .lineLimit(1)
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(PSColor.soft)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(PSColor.soft)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: PSRadius.card).fill(PSColor.cardFill))
        .psHardShadow(radius: PSRadius.card)
    }

    @ViewBuilder
    private func thumbnail(_ contender: BattleContender) -> some View {
        if let uiImage = UIImage(data: contender.imageData) {
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: 8).fill(PSColor.cardFill)
        }
    }
}
