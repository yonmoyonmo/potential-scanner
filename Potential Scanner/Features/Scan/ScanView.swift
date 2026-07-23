//
//  ScanView.swift
//  Potential Scanner
//

import AVFoundation
import Combine
import PhotosUI
import SwiftUI

struct ScanView: View {
    @State private var viewModel = ScanViewModel()
    var onFinished: (ScanResult) -> Void
    var onCancel: () -> Void

    @State private var hapticPulse = 0
    @State private var captureHapticTrigger = 0
    @State private var captureFlash = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?

    private var isScanning: Bool {
        if case .scanning = viewModel.phase { return true }
        return false
    }

    private let hapticTimer = Timer.publish(every: 1.4, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if let pickedImage {
                GeometryReader { geo in
                    Image(uiImage: pickedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
            } else {
                CameraPreview(session: viewModel.camera.session)
                    .ignoresSafeArea()
            }

            if case .idle = viewModel.phase {
                ScanFramingGuide()
            }

            if case .scanning = viewModel.phase {
                ScanOverlayView(isScanning: true)
                    .ignoresSafeArea()
                ScanHUDView(isScanning: true)
                    .ignoresSafeArea()
                ScanGlitchView(isScanning: true)
                    .ignoresSafeArea()
            }

            Color.white
                .opacity(captureFlash ? 1 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack {
                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Circle().fill(.black.opacity(0.4)))
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                switch viewModel.phase {
                case .idle:
                    VStack(spacing: 12) {
                        PSButton(title: String(localized: String.LocalizationValue("ui.home.scanButton"))) {
                            Task { await viewModel.startScan() }
                        }

                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            Text(String(localized: String.LocalizationValue("ui.scan.pickPhotoButton")))
                                .font(PSTypography.summary)
                                .foregroundStyle(PSColor.ink)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: PSRadius.card)
                                        .fill(PSColor.cardFill)
                                )
                        }
                        .psHardShadow(radius: PSRadius.card)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)

                case .scanning:
                    Text(CommentPool.text(forID: viewModel.loadingLineID))
                        .font(PSTypography.body)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(.black.opacity(0.4)))
                        .padding(.bottom, 60)

                case .finished:
                    EmptyView()
                }
            }
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                guard
                    let data = try? await newItem.loadTransferable(type: Data.self),
                    let image = UIImage(data: data)
                else { return }
                pickedImage = image
                await viewModel.startScan(with: image)
            }
        }
        .onReceive(hapticTimer) { _ in
            if isScanning { hapticPulse += 1 }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: hapticPulse)
        .sensoryFeedback(.success, trigger: captureHapticTrigger)
        .onChange(of: viewModel.phase) { _, newPhase in
            guard case .finished(let result) = newPhase else { return }
            captureHapticTrigger += 1
            withAnimation(.linear(duration: 0.05)) { captureFlash = true }
            Task {
                try? await Task.sleep(for: .milliseconds(120))
                withAnimation(.easeOut(duration: 0.25)) { captureFlash = false }
                onFinished(result)
            }
        }
    }
}

extension ScanViewModel.Phase: Equatable {
    static func == (lhs: ScanViewModel.Phase, rhs: ScanViewModel.Phase) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.scanning, .scanning), (.finished, .finished):
            return true
        default:
            return false
        }
    }
}

private struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    final class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
