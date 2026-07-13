//
//  PSTypography.swift
//  Potential Scanner
//
//  로케일별 폰트 매핑 지점. 지금은 ko/en 모두 Sam3KRFont를 쓰고,
//  ja는 Sam3KRFont에 해당 글리프가 없어 시스템 폰트로 폴백한다.
//  일본어 전용 폰트가 확보되면 이 매핑 한 곳만 바꾸면 된다.
//

import SwiftUI

enum PSTypography {
    private static var localizedFontName: String? {
        switch Locale.current.language.languageCode?.identifier {
        case "ja":
            return nil // 시스템 폰트 폴백
        default:
            return "Sam3KRFont"
        }
    }

    static func font(size: CGFloat) -> Font {
        if let name = localizedFontName {
            return .custom(name, size: size)
        }
        return .system(size: size)
    }

    static var heroTitle: Font { font(size: 34) }
    static var pageTitle: Font { font(size: 26) }
    static var summary: Font { font(size: 18) }
    static var body: Font { font(size: 17) }
}

extension View {
    /// `.navigationTitle`은 UIKit 네비게이션 바가 그리는 텍스트라 SwiftUI Font가 안 먹는다.
    /// principal 툴바 아이템에 직접 Text를 그려서 커스텀 폰트를 적용한다.
    func psNavigationTitle(_ localizationKey: String) -> some View {
        navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: String.LocalizationValue(localizationKey)))
                        .font(PSTypography.pageTitle)
                        .foregroundStyle(PSColor.ink)
                }
            }
    }
}
