//
//  ScanOverlayView.swift
//  Potential Scanner
//
//  스캔 중 재생되는 그리드/레이더/스캔라인 연출. 눈에 확 띄도록 두껍게, 스캔 진행 중
//  주기적으로 색이 바뀌는 네온 톤으로 구성.
//

import Combine
import SwiftUI

struct ScanOverlayView: View {
    var isScanning: Bool

    @State private var scanLineProgress: CGFloat = 0
    @State private var radarRotation: Angle = .zero
    @State private var colorIndex = 0

    private let colorCycleTimer = Timer.publish(every: 0.7, on: .main, in: .common).autoconnect()

    private let vividColors: [Color] = [
        PSColor.skyStrong, PSColor.signalAmber, PSColor.signalMagenta, PSColor.grassMid,
    ]

    private var currentColor: Color { vividColors[colorIndex % vividColors.count] }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                gridLines(in: proxy.size)

                Circle()
                    .strokeBorder(currentColor, lineWidth: 3)
                    .frame(width: proxy.size.width * 0.7)
                    .overlay(
                        Rectangle()
                            .fill(currentColor)
                            .frame(width: proxy.size.width * 0.35, height: 4)
                            .offset(x: proxy.size.width * 0.175)
                            .rotationEffect(radarRotation)
                    )
                    .shadow(color: currentColor.opacity(0.8), radius: 8)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, currentColor, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 8)
                    .shadow(color: currentColor.opacity(0.9), radius: 10)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * scanLineProgress)
            }
        }
        .allowsHitTesting(false)
        .onAppear { startAnimationsIfNeeded() }
        .onChange(of: isScanning) { _, _ in startAnimationsIfNeeded() }
        .onReceive(colorCycleTimer) { _ in
            guard isScanning else { return }
            colorIndex += 1
        }
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
        .stroke(currentColor.opacity(0.28), lineWidth: 1)
    }
}
