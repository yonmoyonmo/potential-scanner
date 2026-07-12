//
//  HomeView.swift
//  Potential Scanner
//

import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            PSColor.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Text(String(localized: String.LocalizationValue("ui.home.title")))
                    .font(PSTypography.heroTitle)
                    .foregroundStyle(PSColor.ink)

                PSButton(title: String(localized: String.LocalizationValue("ui.home.scanButton"))) {
                    path.append(AppRoute.scan)
                }
                .padding(.horizontal, 40)

                PSButton(
                    title: String(localized: String.LocalizationValue("ui.home.cardListButton")),
                    isProminent: false
                ) {
                    path.append(AppRoute.cardList)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}
