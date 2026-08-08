//
//  ScanFramingGuide.swift
//  Potential Scanner
//
//  스캔 전 프레이밍 가이드. 카드 사진 비율(3:4)로 창을 뚫어, 여기 보이는 그대로가
//  카드에 들어가도록 한다 — 가이드 박스와 실제 크롭 영역은 같은 `ScanFraming.cropRect`
//  하나에서 나오므로 둘이 어긋날 수 없다.
//

import SwiftUI

enum ScanFraming {
    /// 화면(세이프에어리어 포함 전체) 안에서 카드 사진으로 잘려 나갈 영역.
    ///
    /// ⚠️ 여기 넘기는 `containerSize`는 반드시 세이프에어리어를 무시한 전체 화면 크기여야
    /// 한다. 카메라 프리뷰 레이어가 `.ignoresSafeArea()`로 전체 화면을 차지하므로,
    /// 크롭 역산도 같은 좌표계에서 해야 노치/홈바 높이만큼 어긋나지 않는다.
    static func cropRect(in containerSize: CGSize) -> CGRect {
        guard containerSize.width > 0, containerSize.height > 0 else { return .zero }

        // 가로를 최대한 쓰되, 상단 닫기 버튼과 하단 스캔 버튼에 자리를 남긴다.
        let maxWidth = containerSize.width * 0.86
        let maxHeight = containerSize.height * 0.58

        var width = maxWidth
        var height = width / CardCanvas.photoAspectRatio
        if height > maxHeight {
            height = maxHeight
            width = height * CardCanvas.photoAspectRatio
        }

        return CGRect(
            x: (containerSize.width - width) / 2,
            y: (containerSize.height - height) / 2,
            width: width,
            height: height
        )
    }
}

struct ScanFramingGuide: View {
    let cropRect: CGRect
    /// 조준 단계에선 바깥을 어둡게 깔아 대상을 맞추게 하고, 스캔 연출 중에는
    /// 연출을 가리지 않도록 테두리만 남긴다(셔터는 연출이 끝난 뒤에 눌리므로
    /// 그동안에도 프레임 기준은 계속 보여야 한다).
    var dimsSurroundings: Bool = true

    var body: some View {
        ZStack {
            Color.clear

            if dimsSurroundings {
                ZStack {
                    Rectangle().fill(.black.opacity(0.4))
                    window.blendMode(.destinationOut)
                }
                .compositingGroup()
            }

            CRTBorder(shape: window)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    /// 프레임+position 조합 대신 절대 좌표로 한 번에 그린다 — 크롭에 쓰는 rect와
    /// 화면에 보이는 창이 같은 숫자에서 나와야 어긋날 여지가 없다.
    private var window: WindowShape {
        WindowShape(rect: cropRect)
    }
}

private struct WindowShape: Shape {
    let rect: CGRect

    func path(in _: CGRect) -> Path {
        RoundedRectangle(cornerRadius: PSRadius.card).path(in: rect)
    }
}
