//
//  ScanViewModel.swift
//  Potential Scanner
//

import UIKit

@Observable
final class ScanViewModel {
    enum Phase {
        case idle
        case scanning
        case finished(ScanResult)
    }

    private(set) var phase: Phase = .idle
    private(set) var loadingLineID: String = CommentPool.loadingLineIDs.randomElement() ?? "loading.001"

    let camera = CameraService()

    func onAppear() {
        camera.requestAccessAndConfigure()
    }

    func onDisappear() {
        camera.stop()
    }

    /// 카메라로 직접 촬영해서 스캔. 연출이 끝난 뒤에 셔터를 눌러, 조준하고
    /// 기다렸다 찍는 느낌을 준다 (연출 중엔 라이브 카메라 프리뷰가 계속 보임).
    ///
    /// `guideRect`/`containerSize`는 화면에 그려진 조준 가이드와 **세이프에어리어를 무시한
    /// 전체 화면 크기**다. 프리뷰 레이어가 이 크기에 aspect-fill로 깔려 있으므로,
    /// 그 변환을 역산하면 가이드 안에 보이던 영역만 정확히 잘라낼 수 있다.
    @MainActor
    func startScan(guideRect: CGRect, containerSize: CGSize) async {
        guard case .idle = phase else { return }
        phase = .scanning

        await playScanningAnimation()
        let photo = await camera.capturePhoto() ?? UIImage()
        finish(with: cropToGuide(photo, guideRect: guideRect, containerSize: containerSize))
    }

    /// 사진 라이브러리에서 고른 이미지로 스캔. 이미 크롭 에디터에서 확정된 이미지라
    /// 여기서 추가로 자르지 않는다 (자르면 사용자가 맞춘 프레임이 다시 어긋난다).
    @MainActor
    func startScan(with croppedImage: UIImage) async {
        guard case .idle = phase else { return }
        phase = .scanning

        await playScanningAnimation()
        finish(with: croppedImage)
    }

    func reset() {
        phase = .idle
    }

    @MainActor
    private func playScanningAnimation() async {
        let loadingTask = Task { await cycleLoadingLines() }
        let duration = Double.random(in: 2...4)
        try? await Task.sleep(for: .seconds(duration))
        loadingTask.cancel()
    }

    /// 촬영본에서 조준 가이드 안쪽만 잘라낸다.
    ///
    /// 세션 프리셋이 `.photo`라 촬영본은 이미 3:4다. 그래서 예전처럼 3:4 중앙 크롭을
    /// 걸면 아무것도 잘리지 않고 센서 프레임 전체가 카드에 들어갔다 — 화면엔 좌우가
    /// 잘린 채로 보이는데도. 가이드 rect를 역산해 자르는 게 그 불일치의 해법이다.
    private func cropToGuide(_ photo: UIImage, guideRect: CGRect, containerSize: CGSize) -> UIImage {
        let upright = photo.normalizedOrientation()

        guard
            !guideRect.isEmpty,
            let normalized = CropGeometry.normalizedRect(
                of: guideRect,
                in: CropGeometry.aspectFillFrame(imageSize: upright.size, in: containerSize)
            ),
            let cropped = upright.cropped(toNormalized: normalized)
        else {
            // 가이드 좌표를 못 구했으면 최소한 카드 비율은 맞도록 중앙 크롭으로 떨어진다.
            return photo.croppedToAspect(widthToHeight: CardCanvas.photoAspectRatio)
        }

        return cropped
    }

    private func finish(with photo: UIImage) {
        let result = ScanResultGenerator.generate(from: photo)
        phase = .finished(result)
    }

    @MainActor
    private func cycleLoadingLines() async {
        while !Task.isCancelled {
            loadingLineID = CommentPool.loadingLineIDs.randomElement() ?? loadingLineID
            try? await Task.sleep(for: .milliseconds(700))
        }
    }
}
