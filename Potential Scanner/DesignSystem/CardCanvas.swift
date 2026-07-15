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
}
