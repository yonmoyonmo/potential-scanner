//
//  PhotoCropView.swift
//  Potential Scanner
//
//  사진 라이브러리에서 고른 이미지를 카드에 들어갈 만큼 미리 보고 맞추는 화면.
//  조리개(크롭 창)는 카드 사진과 같은 3:4로 고정하고, 사진 쪽을 확대/이동한다.
//  여기 조리개에 보이는 픽셀이 곧 카드에 들어가는 픽셀이다.
//

import SwiftUI

struct PhotoCropView: View {
    let image: UIImage
    var onConfirm: (UIImage) -> Void
    var onReselect: () -> Void
    var onCancel: () -> Void

    /// 너무 당기면 카드에 쓸 원본 픽셀이 모자라져 뭉개지므로 상한을 둔다.
    private static let maxScale: CGFloat = 4

    @State private var scale: CGFloat = 1
    @State private var committedScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var committedOffset: CGSize = .zero
    /// 화면에 실제로 그려진 조리개 크기. 제스처 제한과 최종 크롭이 모두 이 값을 쓴다.
    @State private var aperture: CGSize = .zero

    var body: some View {
        VStack(spacing: 20) {
            header

            GeometryReader { proxy in
                let size = apertureSize(in: proxy.size)

                aperturePreview(size)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .onAppear { aperture = size }
                    .onChange(of: size) { _, newSize in
                        aperture = newSize
                        offset = clamp(committedOffset, scale: scale, in: newSize)
                        committedOffset = offset
                    }
            }
            .padding(.horizontal, 16)

            controls
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 배경만 화면 끝까지 깔고, 내용은 세이프에어리어 안에 둔다. 배경을 ZStack의
        // 형제로 두면 ZStack 자체가 전체 화면으로 커져서 헤더가 상태바에 물린다.
        .background(PSColor.background.ignoresSafeArea())
    }

    // MARK: - 구성 요소

    private var header: some View {
        ZStack {
            // 배경이 앱 테마 그라데이션(초록–하양–파랑)이라 헤더는 밝은 바탕에 놓인다.
            // 흰 글씨는 가운데 cloud 구간에서 안 보이므로 본문색(ink)을 쓴다.
            Text(String(localized: String.LocalizationValue("ui.scan.cropTitle")))
                .font(PSTypography.body)
                .foregroundStyle(PSColor.ink)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 56)

            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundStyle(PSColor.ink)
                        .padding(12)
                        .background(Circle().fill(PSColor.cardFill))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }

    private func aperturePreview(_ size: CGSize) -> some View {
        Color.clear
            .frame(width: size.width, height: size.height)
            .overlay(
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .scaleEffect(scale)
                    .offset(offset)
            )
            .clipShape(RoundedRectangle(cornerRadius: PSRadius.card))
            .overlay(CRTBorder(shape: RoundedRectangle(cornerRadius: PSRadius.card)))
            .contentShape(Rectangle())
            .gesture(dragGesture(size))
            .simultaneousGesture(magnifyGesture(size))
    }

    private var controls: some View {
        VStack(spacing: 12) {
            PSButton(title: String(localized: String.LocalizationValue("ui.scan.cropConfirm"))) {
                guard let cropped = makeCroppedImage() else { return }
                onConfirm(cropped)
            }

            PSButton(
                title: String(localized: String.LocalizationValue("ui.scan.cropReselect")),
                isProminent: false,
                action: onReselect
            )
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 16)
    }

    // MARK: - 제스처

    private func dragGesture(_ size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let moved = CGSize(
                    width: committedOffset.width + value.translation.width,
                    height: committedOffset.height + value.translation.height
                )
                offset = clamp(moved, scale: scale, in: size)
            }
            .onEnded { _ in committedOffset = offset }
    }

    private func magnifyGesture(_ size: CGSize) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = min(max(committedScale * value.magnification, 1), Self.maxScale)
                scale = newScale
                // 배율을 줄이면 움직일 수 있는 여유도 같이 줄어드니 offset을 다시 조인다.
                offset = clamp(offset, scale: newScale, in: size)
            }
            .onEnded { _ in
                committedScale = scale
                committedOffset = offset
            }
    }

    // MARK: - 계산

    /// 주어진 공간 안에 들어가는 가장 큰 3:4 조리개.
    private func apertureSize(in containerSize: CGSize) -> CGSize {
        guard containerSize.width > 0, containerSize.height > 0 else { return .zero }

        var width = containerSize.width
        var height = width / CardCanvas.photoAspectRatio
        if height > containerSize.height {
            height = containerSize.height
            width = height * CardCanvas.photoAspectRatio
        }
        return CGSize(width: width, height: height)
    }

    private func clamp(_ candidate: CGSize, scale: CGFloat, in size: CGSize) -> CGSize {
        CropGeometry.clampedOffset(
            candidate,
            imageFrame: CropGeometry.aspectFillFrame(imageSize: image.size, in: size),
            scale: scale,
            apertureSize: size
        )
    }

    private func makeCroppedImage() -> UIImage? {
        guard aperture.width > 0, aperture.height > 0 else { return nil }

        let base = CropGeometry.aspectFillFrame(imageSize: image.size, in: aperture)
        guard base.width > 0 else { return nil }

        // 화면에서 이미지가 실제로 차지하고 있는 프레임을 그대로 재현한 뒤,
        // 조리개 사각형이 원본의 어느 영역인지 역산한다.
        let displayed = CropGeometry.transformed(base, scale: scale, offset: offset, in: aperture)
        guard let normalized = CropGeometry.normalizedRect(
            of: CGRect(origin: .zero, size: aperture),
            in: displayed
        ) else { return nil }

        return image.cropped(toNormalized: normalized)
    }
}
