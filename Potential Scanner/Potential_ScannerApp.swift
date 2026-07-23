//
//  Potential_ScannerApp.swift
//  Potential Scanner
//
//  Created by yowenomo on 7/12/26.
//

import SwiftUI
import SwiftData

@main
struct Potential_ScannerApp: App {
    let modelContainer: ModelContainer = Self.makeModelContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }

    /// 개발 중에는 ScanCard 스키마가 자주 바뀔 수 있는데, 기기에 이미 옛 스키마로 저장된
    /// 로컬 DB가 있으면 자동 마이그레이션이 실패해 컨테이너 생성 자체가 죽을 수 있다.
    /// 실패 시 기존 로컬 저장소를 지우고 새로 만들어 앱이 항상 뜨도록 한다
    /// (아직 실 사용자 데이터가 없는 개발 단계라 로컬 카드 데이터 유실은 감수).
    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([ScanCard.self, BattleRecord.self])
        let configuration = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            try? FileManager.default.removeItem(at: configuration.url)
            return try! ModelContainer(for: schema, configurations: [configuration])
        }
    }
}
