//
//  PSTypography.swift
//  Potential Scanner
//
//  로케일별 폰트 매핑 지점. ko/en은 도트 한글 폰트 Sam3KRFont,
//  ja는 도트 일본어 폰트 PixelMplus12로 매핑한다(둘 다 픽셀/도트 톤이라 결이 맞음).
//

import SwiftUI

enum PSTypography {
    private static var localizedFontName: String {
        switch Locale.current.language.languageCode?.identifier {
        case "ja":
            return "PixelMplus12-Regular"
        default:
            return "Sam3KRFont"
        }
    }

    static func font(size: CGFloat) -> Font {
        .custom(localizedFontName, size: size)
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
