//
//  CropGeometry.swift
//  Potential Scanner
//
//  "화면에 보이는 사각형이 원본 이미지의 어느 부분인가"를 되돌리는 계산.
//  카메라 조준 가이드와 사진 크롭 에디터가 완전히 같은 식을 쓰기 위해 한 곳에 모았다.
//
//  두 경우 모두 이미지는 컨테이너에 aspect-fill로 깔린다(모자란 쪽을 채우고 남는 쪽은
//  넘쳐서 잘림). 그래서 "이미지가 컨테이너 좌표계에서 차지하는 프레임"만 알면,
//  거기서 역산해 원본의 정규화(0~1) 크롭 영역을 구할 수 있다.
//

import CoreGraphics

enum CropGeometry {
    /// `imageSize`를 `containerSize`에 aspect-fill로 채웠을 때 이미지가 차지하는 프레임.
    /// 컨테이너보다 항상 크거나 같고, 가운데 정렬이므로 원점이 음수가 될 수 있다.
    static func aspectFillFrame(imageSize: CGSize, in containerSize: CGSize) -> CGRect {
        guard
            imageSize.width > 0, imageSize.height > 0,
            containerSize.width > 0, containerSize.height > 0
        else { return .zero }

        let scale = max(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        return CGRect(
            x: (containerSize.width - size.width) / 2,
            y: (containerSize.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
    }

    /// 가운데를 기준으로 `scale`만큼 확대하고 `offset`만큼 민 프레임.
    /// SwiftUI의 `.scaleEffect(scale).offset(offset)` 조합과 같은 결과를 계산으로 재현한다
    /// (scaleEffect는 뷰 자신의 중심을 기준으로 확대하고, offset은 그 뒤에 평행이동).
    static func transformed(
        _ frame: CGRect,
        scale: CGFloat,
        offset: CGSize,
        in containerSize: CGSize
    ) -> CGRect {
        let size = CGSize(width: frame.width * scale, height: frame.height * scale)
        let center = CGPoint(
            x: containerSize.width / 2 + offset.width,
            y: containerSize.height / 2 + offset.height
        )
        return CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    /// 컨테이너 좌표계의 `rect`가 원본 이미지의 어느 영역인지 0~1 정규화 좌표로 되돌린다.
    /// `imageFrame`은 같은 컨테이너 좌표계에서 이미지가 차지하는 프레임.
    static func normalizedRect(of rect: CGRect, in imageFrame: CGRect) -> CGRect? {
        guard imageFrame.width > 0, imageFrame.height > 0 else { return nil }

        let normalized = CGRect(
            x: (rect.minX - imageFrame.minX) / imageFrame.width,
            y: (rect.minY - imageFrame.minY) / imageFrame.height,
            width: rect.width / imageFrame.width,
            height: rect.height / imageFrame.height
        )

        // 부동소수 오차나 예상 밖 입력으로 이미지 밖을 가리키면 잘라서 맞춘다.
        let clamped = normalized.intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
        guard !clamped.isNull, clamped.width > 0, clamped.height > 0 else { return nil }
        return clamped
    }

    /// 확대/이동해도 조리개(크롭 창)가 항상 이미지로 꽉 차도록 offset을 제한한다.
    /// 이걸 안 걸면 사진을 끝까지 밀었을 때 조리개에 빈 공간이 생긴다.
    static func clampedOffset(
        _ offset: CGSize,
        imageFrame: CGRect,
        scale: CGFloat,
        apertureSize: CGSize
    ) -> CGSize {
        let scaledWidth = imageFrame.width * scale
        let scaledHeight = imageFrame.height * scale
        let slackX = max(0, (scaledWidth - apertureSize.width) / 2)
        let slackY = max(0, (scaledHeight - apertureSize.height) / 2)
        return CGSize(
            width: min(max(offset.width, -slackX), slackX),
            height: min(max(offset.height, -slackY), slackY)
        )
    }
}
