//
//  CRTBorder.swift
//  Potential Scanner
//
//  스캔 화면 전체가 하나의 브라운관처럼 보이도록 하는 공통 인광 연출.
//  조준 가이드, 크롭 조리개, 스캔 연출의 선들이 전부 여기서 나온다.
//
//  선 하나는 세 겹으로 그린다:
//    1. 테두리에 바짝 붙은 인광 번짐(blur)
//    2. 본선 + 글로우
//    3. 가장 세게 타는 가운데 심지(거의 흰색)
//

import Combine
import SwiftUI

enum CRT {
    static let color = PSColor.terminalGreen
}

/// 느린 호흡 + 불규칙한 깜빡임을 만들어 자식에게 밝기(0~1)로 넘긴다.
///
/// 한 화면에 하나만 두고 공유해야 화면 안의 CRT 요소들이 **같이** 떨린다.
/// 요소마다 따로 두면 제각각 깜빡여서 브라운관 하나가 아니라 고장난 전광판이 된다.
struct CRTFlicker<Content: View>: View {
    @ViewBuilder var content: (CGFloat) -> Content

    /// 밝기가 느리게 오르내리는 기본 호흡.
    @State private var breath: CGFloat = 0.78
    /// 가끔 순간적으로 어두워지는 깜빡임. 호흡과 곱해서 최종 밝기를 만든다.
    @State private var blink: CGFloat = 1

    /// 일정 주기로 훑되 매번 깜빡이진 않는다 — 규칙적으로 뛰면 CRT가 아니라 신호등이다.
    private let blinkTimer = Timer.publish(every: 0.28, on: .main, in: .common).autoconnect()

    var body: some View {
        content(breath * blink)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    breath = 1
                }
            }
            .onReceive(blinkTimer) { _ in
                guard Double.random(in: 0...1) < 0.18 else { return }

                blink = CGFloat.random(in: 0.35...0.6)
                // 어두워진 상태를 한 프레임 이상 보여준 뒤에 복구해야 실제로 깜빡여 보인다.
                // 같은 사이클에서 곧바로 되돌리면 SwiftUI가 합쳐버려 아무 일도 안 일어난다.
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(40))
                    withAnimation(.easeOut(duration: 0.18)) { blink = 1 }
                }
            }
    }
}

/// 인광 세 겹으로 그린 선. 밝기는 바깥에서 받는다 — 같은 화면의 다른 CRT 요소들과
/// 함께 떨려야 하므로 스스로 애니메이션하지 않는다.
struct CRTStroke<S: Shape>: View {
    let shape: S
    var lineWidth: CGFloat = 3
    var glow: CGFloat

    var body: some View {
        ZStack {
            // 번짐은 선에 바짝 붙여 둔다. 넓게 퍼뜨리면 창 안쪽까지 초록 안개가 껴서
            // 정작 뭘 담고 있는지 안 보인다 — 조준 가이드로서는 본말전도.
            shape
                .stroke(CRT.color.opacity(0.5 * glow), lineWidth: lineWidth * 1.8)
                .blur(radius: 3.5)

            shape
                .stroke(CRT.color.opacity(0.95 * glow), lineWidth: lineWidth)
                .shadow(color: CRT.color.opacity(0.6 * glow), radius: 3.5)

            shape
                .stroke(Color.white.opacity(0.45 * glow), lineWidth: lineWidth * 0.3)
        }
    }
}

/// 스스로 떠는 인광 테두리. 조준 가이드와 크롭 조리개처럼 화면에 하나만 있는 경우에 쓴다.
struct CRTBorder<S: Shape>: View {
    let shape: S
    var lineWidth: CGFloat = 3

    var body: some View {
        CRTFlicker { glow in
            CRTStroke(shape: shape, lineWidth: lineWidth, glow: glow)
        }
        .allowsHitTesting(false)
    }
}

extension View {
    /// Shape가 아니어서 세 겹으로 못 그리는 요소(레이더 바, 스캔 라인 등)에 인광만 입힌다.
    func crtGlow(_ glow: CGFloat, radius: CGFloat = 3.5) -> some View {
        shadow(color: CRT.color.opacity(0.7 * glow), radius: radius)
            .shadow(color: CRT.color.opacity(0.4 * glow), radius: radius * 2.2)
    }
}
