//
//  ScanView.swift
//  Potential Scanner
//

import SwiftUI
import AVFoundation

struct ScanView: View {
    @State private var viewModel = ScanViewModel()
    var onFinished: (ScanResult) -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.camera.session)
                .ignoresSafeArea()

            if case .scanning = viewModel.phase {
                ScanOverlayView(isScanning: true)
                    .ignoresSafeArea()
            }

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
                    PSButton(title: String(localized: String.LocalizationValue("ui.home.scanButton"))) {
                        Task { await viewModel.startScan() }
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
        .onChange(of: viewModel.phase) { _, newPhase in
            if case .finished(let result) = newPhase {
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
