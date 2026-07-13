//
//  SplashView.swift
//  Potential Scanner
//
//  앱 실행 직후 잠깐 노출되는 인앱 스플래시. 네이티브 런치 스크린(Info.plist
//  UILaunchScreen)이 배경색으로 먼저 뜨고, 그 위를 이 화면이 이어받아
//  로고/타이틀을 보여준 뒤 홈으로 넘어간다.
//

import SwiftUI

struct SplashView: View {
    @State private var isVisible = false

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.92)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
        }
    }
}
