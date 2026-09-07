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
    private var currentInput: AVCaptureDeviceInput?
    /// sessionQueue에서만 읽고 쓴다. UI(메인 스레드)에서 직접 참조하지 말 것.
    private var position: AVCaptureDevice.Position = .back

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
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        currentInput = input

        guard session.canAddOutput(photoOutput) else {
            session.commitConfiguration()
            return
        }
        session.addOutput(photoOutput)
        session.commitConfiguration()
        session.startRunning()
    }

    /// 셀피 스캔용 전/후면 전환. 프리뷰는 `AVCaptureVideoPreviewLayer`가 알아서
    /// 좌우 반전해주지만, 실제 캡처본은 그렇지 않아서 전면일 때만 수동으로 반전시켜
    /// 사용자가 프리뷰에서 본 그대로(거울상)가 카드 사진으로 저장되게 한다.
    func switchCamera() {
        sessionQueue.async {
            let newPosition: AVCaptureDevice.Position = self.position == .back ? .front : .back
            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                let newInput = try? AVCaptureDeviceInput(device: device)
            else { return }

            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }

            if let currentInput = self.currentInput {
                self.session.removeInput(currentInput)
            }
            guard self.session.canAddInput(newInput) else {
                // 실패 시 원래 입력 복구.
                if let currentInput = self.currentInput { self.session.addInput(currentInput) }
                return
            }
            self.session.addInput(newInput)
            self.currentInput = newInput
            self.position = newPosition
            self.updateMirroring()
        }
    }

    private func updateMirroring() {
        guard let connection = photoOutput.connection(with: .video) else { return }
        connection.automaticallyAdjustsVideoMirroring = false
        connection.isVideoMirrored = position == .front
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
