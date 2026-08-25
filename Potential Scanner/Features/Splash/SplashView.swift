//
//  SplashView.swift
//  Potential Scanner
//
//  앱 실행 직후 잠깐 노출되는 인앱 스플래시. 네이티브 런치 스크린(Info.plist
//  UILaunchScreen)이 배경색으로 먼저 뜨고, 그 위를 이 화면이 이어받아
//  yowenomo studio 로고 → YCGS 로고 순으로 크로스페이드한 뒤 홈으로 넘어간다.
//
//  배경색과 로고 이미지를 하나의 Bool 상태로 묶어 통째로 크로스페이드 시킨다.
//  (배경 opacity와 로고 opacity를 따로따로 걸면 두 애니메이션이 미묘하게
//  어긋나 보일 수 있어서, 반드시 if/else + 단일 .animation(value:)로 원자적으로 전환한다.)
//

import SwiftUI

struct SplashView: View {
    @State private var showStudioLogo = true

    var body: some View {
        ZStack {
            if showStudioLogo {
                ZStack {
                    PSColor.background.ignoresSafeArea()
                    Image("logo")
                        .resizable().scaledToFit()
                        .frame(maxWidth: 260)
                }
                .transition(.opacity)
            } else {
                ZStack {
                    PSColor.skyStrong.ignoresSafeArea()
                    Image("YCGSLogo")
                        .resizable().scaledToFit()
                        .frame(maxWidth: 200)
                }
                .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: showStudioLogo)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                showStudioLogo = false
            }
        }
    }
}
