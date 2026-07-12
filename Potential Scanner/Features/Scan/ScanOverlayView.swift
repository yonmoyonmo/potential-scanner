//
//  ScanOverlayView.swift
//  Potential Scanner
//
//  스캔 중 재생되는 그리드/레이더/스캔라인 연출.
//

import SwiftUI

struct ScanOverlayView: View {
    var isScanning: Bool

    @State private var scanLineProgress: CGFloat = 0
    @State private var radarRotation: Angle = .zero

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                gridLines(in: proxy.size)

                Circle()
                    .strokeBorder(PSColor.skyStrong.opacity(0.6), lineWidth: 1.5)
                    .frame(width: proxy.size.width * 0.7)
                    .overlay(
                        Rectangle()
                            .fill(PSColor.skyStrong.opacity(0.5))
                            .frame(width: proxy.size.width * 0.35, height: 1.5)
                            .offset(x: proxy.size.width * 0.175)
                            .rotationEffect(radarRotation)
                    )
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, PSColor.skyStrong.opacity(0.55), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 3)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * scanLineProgress)
            }
        }
        .allowsHitTesting(false)
        .onAppear { startAnimationsIfNeeded() }
        .onChange(of: isScanning) { _, _ in startAnimationsIfNeeded() }
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

    private func gridLines(in size: CGSize) -> some View {
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
        .stroke(PSColor.skyStrong.opacity(0.15), lineWidth: 0.5)
    }
}
