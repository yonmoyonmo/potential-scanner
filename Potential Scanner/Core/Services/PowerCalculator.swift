//
//  PowerCalculator.swift
//  Potential Scanner
//
//  전투력 산출: 대상 구분 없이 0~10,000,000 범위에서 완전 균등 랜덤.
//  (기획: 카테고리별 사전 가중치 없음, 티스푼이 사람보다 세게 나오는 게 의도된 재미)
//

import UIKit

enum PowerCalculator {
    static let range = 0...10_000_000

    static func power(from image: UIImage) -> Int {
        Int.random(in: range)
    }
}
