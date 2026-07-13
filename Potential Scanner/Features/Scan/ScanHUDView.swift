//
//  ScanHUDView.swift
//  Potential Scanner
//
//  네 귀퉁이에 좌표/주파수/온도 등 가짜 수치가 빠르게 틱틱 올라가는 SF 스캐너 느낌의 HUD.
//  실제 의미는 없고 전부 랜덤 — 장난감 스캐너 컨셉을 강조하는 순수 연출용.
//

import Combine
import SwiftUI

struct ScanHUDView: View {
    var isScanning: Bool

    @State private var coordinateValue = "00.0000, 00.0000"
    @State private var frequencyValue = 0
    @State private var tempValue = 0.0

    private let tickTimer = Timer.publish(every: 0.12, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                hudLabel("COORD", coordinateValue)
                Spacer()
                hudLabel("FREQ", "\(frequencyValue) Hz", alignment: .trailing)
            }
            Spacer()
            HStack(alignment: .bottom) {
                hudLabel("TEMP", String(format: "%.1f°", tempValue))
                Spacer()
                hudLabel("STATUS", isScanning ? "SCANNING" : "IDLE", alignment: .trailing)
            }
        }
        .padding(20)
        .padding(.top, 40)
        .allowsHitTesting(false)
        .onReceive(tickTimer) { _ in
            guard isScanning else { return }
            tick()
        }
    }

    private func hudLabel(_ title: String, _ value: String, alignment: HorizontalAlignment = .leading) -> some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(PSColor.terminalGreen.opacity(0.7))
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(PSColor.terminalGreen)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func tick() {
        coordinateValue = String(format: "%.4f, %.4f", Double.random(in: -90...90), Double.random(in: -180...180))
        frequencyValue = Int.random(in: 100...9999)
        tempValue = Double.random(in: -40...120)
    }
}
