//
//  PowerCalculator.swift
//  Potential Scanner
//
//  전투력 산출: 사진의 밝기/색상 분포를 시드로 쓰는 것처럼 보이되,
//  실제로는 대상 구분 없이 1~999,999 범위에서 고르게 랜덤 산출한다.
//  (기획: 카테고리별 사전 가중치 없음, 티스푼이 사람보다 세게 나오는 게 의도된 재미)
//

import UIKit

enum PowerCalculator {
    static func power(from image: UIImage) -> Int {
        let seed = pixelSeed(of: image)
        var generator = SeededGenerator(seed: seed)
        return Int.random(in: 1...999_999, using: &generator)
    }

    /// 사진의 평균 밝기/채널 값을 정수 시드로 환산.
    /// 결과 자체는 완전히 고르게 랜덤이어야 하므로(콘텐츠.md 참고),
    /// 이 시드는 "그럴듯한 근거가 있는 척"하는 연출용일 뿐 분포에 편향을 주지 않는다.
    private static func pixelSeed(of image: UIImage) -> UInt64 {
        guard let cgImage = image.cgImage,
              let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            return UInt64(Date().timeIntervalSince1970 * 1000)
        }

        let length = CFDataGetLength(data)
        guard length > 0 else { return UInt64(Date().timeIntervalSince1970 * 1000) }

        var accumulator: UInt64 = 1_469_598_103_934_665_603 // FNV offset basis
        let stride = max(1, length / 4096)
        var i = 0
        while i < length {
            accumulator = (accumulator ^ UInt64(bytes[i])) &* 1_099_511_628_211 // FNV prime
            i += stride
        }
        accumulator ^= UInt64(Date().timeIntervalSince1970 * 1000)
        return accumulator
    }
}

/// 시드를 넣을 수 있는 결정적 난수 생성기 (재현 가능한 랜덤을 위해 사용, 매 스캔마다 새 시드로 초기화됨)
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0xDEADBEEF : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
