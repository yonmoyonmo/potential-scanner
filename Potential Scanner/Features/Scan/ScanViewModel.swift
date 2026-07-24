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
    @MainActor
    func startScan() async {
        guard case .idle = phase else { return }
        phase = .scanning

        await playScanningAnimation()
        let photo = await camera.capturePhoto() ?? UIImage()
        finish(with: photo)
    }

    /// 사진 라이브러리에서 고른 이미지로 스캔 (카메라 캡처 없이 같은 연출만 재생).
    @MainActor
    func startScan(with providedImage: UIImage) async {
        guard case .idle = phase else { return }
        phase = .scanning

        await playScanningAnimation()
        finish(with: providedImage)
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

    private func finish(with photo: UIImage) {
        // 카드 사진이 3:4로 보이므로, 캡처 이미지도 3:4로 크롭해 프레이밍 가이드와 맞춘다.
        let cropped = photo.croppedToAspect(widthToHeight: 3.0 / 4.0)
        let result = ScanResultGenerator.generate(from: cropped)
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
