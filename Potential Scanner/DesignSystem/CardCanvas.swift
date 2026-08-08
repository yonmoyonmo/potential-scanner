//
//  CardCanvas.swift
//  Potential Scanner
//
//  카드 이미지는 기기(아이폰/아이패드) 화면 크기와 무관하게 항상 동일한 크기/비율로
//  나와야 사진 앱 저장·공유가 일관된다. 트레이딩카드 표준 비율(63:88mm ≈ 0.716)에
//  맞춘 고정 논리 크기 — 화면엔 이 비율을 유지한 채 축소해서 보여주고,
//  내보낼 때는 이 크기를 기준으로 ImageRenderer가 렌더링한다.
//

import Foundation

enum CardCanvas {
    static let size = CGSize(width: 750, height: 1050)
    static var aspectRatio: CGFloat { size.width / size.height }

    /// 카드 안 사진 영역의 가로:세로 비율. 촬영 가이드·크롭 에디터·카드 렌더가
    /// 전부 이 값 하나를 보게 해서, 세 곳이 따로 놀며 어긋나는 일을 막는다.
    ///
    /// 사진 영역은 카드에서 남는 높이를 채우는 유연한 칸이라, 비율을 고정해 두지 않으면
    /// 코멘트 길이에 따라 카드마다 모양이 달라진다 — 그러면 어떤 크롭 비율로도 맞출 수 없다.
    static let photoAspectRatio: CGFloat = 4.0 / 3.0
}
