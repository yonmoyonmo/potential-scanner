//
//  CardArtboardView.swift
//  Potential Scanner
//
//  카드 비주얼 원본. 항상 CardCanvas.size(750x1050) 고정 크기로 그려진다 —
//  화면 미리보기든 사진 앱 내보내기든 전부 이 뷰 하나를 기준으로 삼는다.
//  지금은 기존 카드 패널 내용을 고정 캔버스에 옮겨온 1차 버전이고,
//  프레임/뱃지 등 비주얼은 다음 단계에서 계속 다듬는다.
//

import SwiftUI

struct CardArtboardView: View {
    let content: CardArtboardContent

    var body: some View {
        VStack(spacing: 20) {
            PSCard {
                Text(content.displayName)
                    .font(PSTypography.font(size: 68))
                    .foregroundStyle(PSColor.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            starRow

            // 세로로 긴 4:3(3:4) 비율 고정 — 이 VStack의 남는 공간을 꽉 채우는 크기로
            // 자동 계산되므로, 위아래 다른 요소 크기가 바뀌어도 비율이 안 깨진다.
            Color.clear
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    Image(uiImage: content.photo)
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: PSRadius.card))
                .psHardShadow(radius: PSRadius.card)

            PSCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(content.typeLabel)
                            .font(PSTypography.font(size: 40))
                            .foregroundStyle(PSColor.skyStrong)
                        Spacer()
                        Text(
                            "\(String(localized: String.LocalizationValue("ui.result.powerLabel"))) : \(content.power)"
                        )
                        .font(PSTypography.font(size: 38))
                        .foregroundStyle(PSColor.ink)
                    }
                    Text(content.typeDescription)
                        .font(PSTypography.font(size: 34))
                        .foregroundStyle(PSColor.muted)

                    Divider().background(PSColor.divider)

                    Text(content.comment)
                        .font(PSTypography.font(size: 34))
                        .foregroundStyle(PSColor.ink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(content.dateText)
                .font(PSTypography.font(size: 24))
                .foregroundStyle(PSColor.soft)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(28)
        .frame(width: CardCanvas.size.width, height: CardCanvas.size.height)
        .background(PSColor.background)
        .clipped()
    }

    private var starRow: some View {
        HStack(spacing: 4) {
            ForEach(0..<10, id: \.self) { index in
                Text("⭐️")
                    .font(.system(size: 40))
                    .opacity(index < content.starCount ? 1 : 0.18)
            }
        }
    }
}

/// 화면에서 카드 캔버스를 항상 같은 비율로, 주어진 너비에 맞춰 축소해서 보여준다.
struct ScaledCardArtboard: View {
    let content: CardArtboardContent

    var body: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / CardCanvas.size.width
            CardArtboardView(content: content)
                .scaleEffect(scale, anchor: .top)
                .frame(width: proxy.size.width, height: CardCanvas.size.height * scale, alignment: .top)
        }
        .aspectRatio(CardCanvas.aspectRatio, contentMode: .fit)
    }
}
