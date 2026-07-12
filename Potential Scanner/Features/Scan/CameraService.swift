//
//  CameraService.swift
//  Potential Scanner
//
//  AVFoundation 캡처 세션 래퍼. 시뮬레이터에서는 카메라 접근이 안 되므로
//  실기기에서만 실제 프리뷰/캡처가 동작한다.
//
//  AVCapturePhotoCaptureDelegate는 임의의 스레드에서 호출되므로(MainActor 격리 불가),
//  이 클래스는 MainActor에 묶이지 않는 순수 클래스로 두고, 내부 가변 상태는
//  전부 sessionQueue라는 하나의 직렬 큐에서만 접근해 스레드 안전성을 보장한다.
//

@preconcurrency import AVFoundation
import UIKit

final class CameraService: NSObject, @unchecked Sendable {
    let session = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "potentialscanner.camera.session")
    private var photoContinuation: CheckedContinuation<UIImage?, Never>?

    func requestAccessAndConfigure() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self, granted else { return }
            self.sessionQueue.async { self.configureSession() }
        }
    }

    private func configureSession() {
        guard session.inputs.isEmpty else {
            session.startRunning()
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        guard session.canAddOutput(photoOutput) else {
            session.commitConfiguration()
            return
        }
        session.addOutput(photoOutput)
        session.commitConfiguration()
        session.startRunning()
    }

    func stop() {
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    func capturePhoto() async -> UIImage? {
        await withCheckedContinuation { continuation in
            sessionQueue.async {
                self.photoContinuation = continuation
                let settings = AVCapturePhotoSettings()
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let data = error == nil ? photo.fileDataRepresentation() : nil
        sessionQueue.async {
            let continuation = self.photoContinuation
            self.photoContinuation = nil
            guard let data, let image = UIImage(data: data) else {
                continuation?.resume(returning: nil)
                return
            }
            continuation?.resume(returning: image)
        }
    }
}
