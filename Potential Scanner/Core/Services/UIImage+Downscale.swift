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

    /// 지정한 가로:세로 비율로 가운데를 잘라낸 사본. 카드 사진이 3:4로 보이므로
    /// 스캔 캡처를 미리 3:4로 크롭해 두면 프레이밍 가이드와 저장 카드가 일치한다.
    func croppedToAspect(widthToHeight ratio: CGFloat) -> UIImage {
        let w = size.width
        let h = size.height
        var cropW = w
        var cropH = h
        if w / h > ratio {
            cropW = h * ratio      // 너무 넓음 → 좌우를 자른다
        } else {
            cropH = w / ratio      // 너무 김 → 상하를 자른다
        }
        let origin = CGPoint(x: (w - cropW) / 2, y: (h - cropH) / 2)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: cropW, height: cropH))
        return renderer.image { _ in
            // 크롭 영역이 원점에 오도록 이미지를 밀어서 그린다(방향 보정 포함).
            draw(at: CGPoint(x: -origin.x, y: -origin.y))
        }
    }
}
