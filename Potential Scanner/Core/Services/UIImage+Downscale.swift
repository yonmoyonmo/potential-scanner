//
//  UIImage+Downscale.swift
//  Potential Scanner
//

import UIKit

extension UIImage {
    /// 카드 저장용 다운스케일. 원본 캡처 해상도 그대로 저장하면 카드가 쌓일수록
    /// SwiftData 저장 용량이 커지므로, 목록/카드에 필요한 수준으로만 줄인다.
    func downscaled(maxDimension: CGFloat) -> UIImage {
        let largestSide = max(size.width, size.height)
        guard largestSide > maxDimension else { return self }

        let scale = maxDimension / largestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
