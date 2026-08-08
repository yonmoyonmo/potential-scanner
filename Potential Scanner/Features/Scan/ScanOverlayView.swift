//
//  ScanOverlayView.swift
//  Potential Scanner
//
//  스캔 중 재생되는 그리드/레이더/스캔라인 연출. 조준 가이드·크롭 조리개와 같은
//  CRT 인광(terminalGreen)으로 통일해서, 스캔 화면 전체가 브라운관 하나처럼 보이게 한다.
//  밝기는 CRTFlicker 하나에서 받아 모든 선이 함께 떨린다.
//

import SwiftUI

struct ScanOverlayView: View {
    var isScanning: Bool

    @State private var scanLineProgress: CGFloat = 0
    @State private var radarRotation: Angle = .zero

    var body: some View {
        GeometryReader { proxy in
            CRTFlicker { glow in
                ZStack {
                    gridLines(in: proxy.size, glow: glow)

                    radar(in: proxy.size, glow: glow)

                    scanLine(in: proxy.size, glow: glow)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { startAnimationsIfNeeded() }
        .onChange(of: isScanning) { _, _ in startAnimationsIfNeeded() }
    }

    private func radar(in size: CGSize, glow: CGFloat) -> some View {
        // inset은 예전 strokeBorder처럼 선이 원 안쪽에 그려지게 맞추는 것.
        CRTStroke(shape: Circle().inset(by: 1.5), lineWidth: 3, glow: glow)
            .frame(width: size.width * 0.7)
            .overlay(
                Rectangle()
                    .fill(CRT.color.opacity(0.9 * glow))
                    .frame(width: size.width * 0.35, height: 4)
                    .offset(x: size.width * 0.175)
                    .rotationEffect(radarRotation)
                    .crtGlow(glow, radius: 5)
            )
            .position(x: size.width / 2, y: size.height / 2)
    }

    private func scanLine(in size: CGSize, glow: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, CRT.color.opacity(glow), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 8)
            .crtGlow(glow, radius: 6)
            .position(x: size.width / 2, y: size.height * scanLineProgress)
    }

    private func startAnimationsIfNeeded() {
        guard isScanning else { return }
        scanLineProgress = 0
        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: true)) {
            scanLineProgress = 1
        }
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            radarRotation = .degrees(360)
        }
    }

    /// 그리드는 배경 질감이라 인광 번짐을 얹지 않는다 — 화면 전체를 덮는 경로에
    /// 그림자를 걸면 다른 연출들과 겹쳐 값이 비싸고, 초록 안개만 짙어진다.
    private func gridLines(in size: CGSize, glow: CGFloat) -> some View {
        Path { path in
            let columns = 6
            let rows = 10
            for c in 0...columns {
                let x = size.width * CGFloat(c) / CGFloat(columns)
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for r in 0...rows {
                let y = size.height * CGFloat(r) / CGFloat(rows)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
        }
        .stroke(CRT.color.opacity(0.26 * glow), lineWidth: 1)
    }
}
