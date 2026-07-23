//
//  BattleResultArtboardView.swift
//  Potential Scanner
//
//  배틀 결과를 한 장 이미지로 만들기 위한 아트보드. 승자(왼쪽, 강조) vs 패자(오른쪽, 흑백)
//  + 승리 문구 + 상성 문구. 너비만 고정하고 높이는 내용에 맞춰 자라므로 아래 빈 공간이
//  생기지 않는다. 화면 상세와 사진 저장이 이 뷰를 렌더한 같은 이미지를 쓴다.
//

import SwiftUI

enum BattleResultCanvas {
    static let width: CGFloat = 1120
}

struct BattleResultArtboardView: View {
    let outcome: BattleOutcome

    var body: some View {
        VStack(spacing: 28) {
            HStack(alignment: .top, spacing: 28) {
                BattleCardMini(contender: outcome.winner, isWinner: true)
                BattleCardMini(contender: outcome.loser, isWinner: false)
            }

            Text(outcome.victoryLine)
                .font(PSTypography.font(size: 52))
                .foregroundStyle(PSColor.skyStrong)
                .multilineTextAlignment(.center)

            if let message = outcome.message {
                Text(message)
                    .font(PSTypography.font(size: 38))
                    .foregroundStyle(PSColor.ink)
                    .multilineTextAlignment(.center)
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: PSRadius.card).fill(PSColor.cardFill))
                    .psHardShadow(radius: PSRadius.card)
            }
        }
        .padding(40)
        .frame(width: BattleResultCanvas.width)
        .background(PSColor.background)
    }
}

/// 전적 이미지용 콤팩트 카드 — 내용(이름·사진·타입/전투력)에 딱 맞춰 세로 크기가 잡힌다.
private struct BattleCardMini: View {
    let contender: BattleContender
    let isWinner: Bool

    private var type: PotentialType? { PotentialType.find(byID: contender.typeID) }

    var body: some View {
        VStack(spacing: 12) {
            Text(contender.name)
                .font(PSTypography.font(size: 40))
                .foregroundStyle(PSColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: PSRadius.card).fill(PSColor.cardFill))
                .psHardShadow(radius: PSRadius.card)

            Color.clear
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .overlay(
                    Image(uiImage: UIImage(data: contender.imageData) ?? UIImage())
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: PSRadius.card))
                .psHardShadow(radius: PSRadius.card)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(type?.displayLabel ?? contender.typeID)
                        .font(PSTypography.font(size: 30))
                        .foregroundStyle(PSColor.skyStrong)
                    Spacer()
                    Text("\(String(localized: String.LocalizationValue("ui.result.powerLabel"))) : \(contender.power)")
                        .font(PSTypography.font(size: 26))
                        .foregroundStyle(PSColor.ink)
                }
                Text(type?.description ?? "")
                    .font(PSTypography.font(size: 26))
                    .foregroundStyle(PSColor.muted)

                Divider().background(PSColor.divider)

                Text(CommentPool.text(forID: contender.commentID))
                    .font(PSTypography.font(size: 26))
                    .foregroundStyle(PSColor.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(RoundedRectangle(cornerRadius: PSRadius.card).fill(PSColor.cardFill))
            .psHardShadow(radius: PSRadius.card)
        }
        .padding(14)
        .saturation(isWinner ? 1 : 0)
        .opacity(isWinner ? 1 : 0.55)
        .overlay {
            if isWinner {
                RoundedRectangle(cornerRadius: PSRadius.card)
                    .stroke(PSColor.signalAmber, lineWidth: 8)
                    .shadow(color: PSColor.signalAmber, radius: 16)
            }
        }
    }
}
