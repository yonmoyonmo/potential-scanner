//
//  ScanFramingGuide.swift
//  Potential Scanner
//
//  스캔 전 프레이밍 가이드. 카드 사진 비율(3:4 세로)로 가운데 창을 뚫어, 그 안에
//  대상을 맞추도록 유도한다. 캡처 이미지는 이 비율로 크롭되어 카드와 일치한다.
//

import SwiftUI

struct ScanFramingGuide: View {
    var body: some View {
        GeometryReader { proxy in
            let boxHeight = min(proxy.size.height * 0.66, proxy.size.width * 0.9 * 4 / 3)
            let boxWidth = boxHeight * 3 / 4

            ZStack {
                // 바깥은 어둡게, 가운데 3:4 창만 뚫는다.
                ZStack {
                    Rectangle().fill(.black.opacity(0.4))
                    RoundedRectangle(cornerRadius: PSRadius.card)
                        .frame(width: boxWidth, height: boxHeight)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()

                RoundedRectangle(cornerRadius: PSRadius.card)
                    .stroke(PSColor.signalAmber, lineWidth: 3)
                    .frame(width: boxWidth, height: boxHeight)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
