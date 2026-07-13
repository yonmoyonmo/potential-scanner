//
//  ScanGlitchView.swift
//  Potential Scanner
//
//  스캔 중 불규칙하게 번쩍이는 컬러 글리치 바. "이 스캐너 좀 미덥지 않음" 톤을 강조하는 연출.
//

import SwiftUI

struct ScanGlitchView: View {
    var isScanning: Bool

    @State private var opacity: Double = 0
    @State private var offsetX: CGFloat = 0
    @State private var barHeight: CGFloat = 16
    @State private var barY: CGFloat = 100

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(PSColor.signalMagenta.opacity(opacity))
                .frame(width: proxy.size.width, height: barHeight)
                .offset(x: offsetX, y: barY)
                .blendMode(.plusLighter)
                .task(id: isScanning) {
                    guard isScanning else { return }
                    await runGlitchLoop(in: proxy.size)
                }
        }
        .allowsHitTesting(false)
    }

    private func runGlitchLoop(in size: CGSize) async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(.random(in: 0.5...1.4)))
            guard !Task.isCancelled else { break }

            barY = .random(in: 40...max(80, size.height - 80))
            barHeight = .random(in: 8...28)
            offsetX = .random(in: -14...14)

            withAnimation(.linear(duration: 0.04)) { opacity = 0.55 }
            try? await Task.sleep(for: .milliseconds(70))
            withAnimation(.linear(duration: 0.05)) { opacity = 0 }
        }
    }
}
