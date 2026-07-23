//
//  ContentView.swift
//  Potential Scanner
//
//  Created by yowenomo on 7/12/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                HomeView(path: $path)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .scan:
                            ScanView(
                                onFinished: { result in
                                    path.append(AppRoute.result(ScanResultToken(result)))
                                },
                                onCancel: { path.removeLast() }
                            )
                            .navigationBarBackButtonHidden()

                        case .result(let token):
                            ResultView(
                                result: token.result,
                                onSaved: { path.removeLast(path.count) },
                                onCancel: { path.removeLast(path.count) }
                            )
                            .navigationBarBackButtonHidden()

                        case .cardList:
                            CardListView(path: $path)

                        case .cardDetail(let card):
                            CardDetailView(card: card) {
                                path.removeLast()
                            }

                        case .battle:
                            BattleView()

                        case .multiplayerBattle:
                            MultiplayerBattleView()

                        case .history:
                            BattleHistoryView(path: $path)

                        case .battleRecord(let record):
                            BattleRecordDetailView(record: record) {
                                path.removeLast()
                            }
                        }
                    }
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.easeOut(duration: 0.4)) {
                showSplash = false
            }
        }
    }
}
