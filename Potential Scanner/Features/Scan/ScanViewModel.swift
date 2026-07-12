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

    @MainActor
    func startScan() async {
        guard case .idle = phase else { return }
        phase = .scanning

        let loadingTask = Task { await cycleLoadingLines() }
        let duration = Double.random(in: 2...4)
        async let capture = camera.capturePhoto()

        try? await Task.sleep(for: .seconds(duration))
        loadingTask.cancel()

        let photo = await capture ?? UIImage()
        let result = ScanResultGenerator.generate(from: photo)
        phase = .finished(result)
    }

    func reset() {
        phase = .idle
    }

    @MainActor
    private func cycleLoadingLines() async {
        while !Task.isCancelled {
            loadingLineID = CommentPool.loadingLineIDs.randomElement() ?? loadingLineID
            try? await Task.sleep(for: .milliseconds(700))
        }
    }
}
