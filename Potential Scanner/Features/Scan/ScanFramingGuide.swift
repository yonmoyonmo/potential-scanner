//
//  ScanFramingGuide.swift
//  Potential Scanner
//
//  스캔 전 프레이밍 가이드. 가운데에 정방형(1:1) 창을 뚫어 대상을 맞추도록 유도한다.
//  (참고: 실제 캡처/카드 사진은 3:4로 저장되므로 가이드와 저장 비율은 다르다)
//

import SwiftUI

struct ScanFramingGuide: View {
    var body: some View {
        GeometryReader { proxy in
            let boxSide = min(proxy.size.height * 0.5, proxy.size.width * 0.9)

            ZStack {
                // 바깥은 어둡게, 가운데 정방형 창만 뚫는다.
                ZStack {
                    Rectangle().fill(.black.opacity(0.4))
                    RoundedRectangle(cornerRadius: PSRadius.card)
                        .frame(width: boxSide, height: boxSide)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()

                RoundedRectangle(cornerRadius: PSRadius.card)
                    .stroke(PSColor.signalAmber, lineWidth: 3)
                    .frame(width: boxSide, height: boxSide)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
