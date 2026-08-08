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

    /// EXIF 방향 정보를 실제 픽셀에 구워 넣은 사본(`imageOrientation == .up`).
    /// 세로로 찍은 사진은 픽셀 배열이 가로로 눕고 방향 플래그로만 세워져 있어서,
    /// 이 정규화를 건너뛰면 크롭 사각형이 90도 틀어진 엉뚱한 영역을 잘라낸다.
    func normalizedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        guard size.width > 0, size.height > 0 else { return self }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// 0~1 정규화 좌표로 지정한 영역만 잘라낸 사본. 원본 픽셀을 그대로 떼어내므로
    /// 재인코딩/화질 손실이 없다(축소는 저장 시점의 `downscaled(maxDimension:)`가 담당).
    func cropped(toNormalized rect: CGRect) -> UIImage? {
        let upright = normalizedOrientation()
        guard let cgImage = upright.cgImage else { return nil }

        let pixelWidth = CGFloat(cgImage.width)
        let pixelHeight = CGFloat(cgImage.height)
        let pixelRect = CGRect(
            x: rect.minX * pixelWidth,
            y: rect.minY * pixelHeight,
            width: rect.width * pixelWidth,
            height: rect.height * pixelHeight
        )
        .integral
        .intersection(CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))

        guard
            !pixelRect.isNull, pixelRect.width >= 1, pixelRect.height >= 1,
            let cropped = cgImage.cropping(to: pixelRect)
        else { return nil }

        return UIImage(cgImage: cropped, scale: upright.scale, orientation: .up)
    }

    /// 지정한 가로:세로 비율로 가운데를 잘라낸 사본. 가이드 좌표를 못 구했을 때
    /// 최소한 카드 비율은 맞도록 떨어지는 폴백 경로로 쓴다.
    func croppedToAspect(widthToHeight ratio: CGFloat) -> UIImage {
        let w = size.width
        let h = size.height
        guard w > 0, h > 0, ratio > 0 else { return self }
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
