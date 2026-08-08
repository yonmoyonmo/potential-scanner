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
    @State private var isPickerPresented = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var cropCandidate: CropCandidate?
    @State private var pickedImage: UIImage?
    /// 세이프에어리어를 무시한 전체 화면 크기. 카메라 프리뷰 레이어가 이 크기에
    /// aspect-fill로 깔리므로, 크롭 역산도 반드시 같은 좌표계에서 해야 한다.
    @State private var screenSize: CGSize = .zero

    private var isScanning: Bool {
        if case .scanning = viewModel.phase { return true }
        return false
    }

    private var cropRect: CGRect { ScanFraming.cropRect(in: screenSize) }

    private let hapticTimer = Timer.publish(every: 1.4, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            screenMeasure

            background

            if case .idle = viewModel.phase {
                ScanFramingGuide(cropRect: cropRect)
            }

            if case .scanning = viewModel.phase {
                // 셔터는 연출이 끝난 뒤에 눌리므로, 그동안에도 프레임 기준은 계속 보여야
                // 피사체가 창 밖으로 흘러나가지 않는다. 연출은 가리지 않게 테두리만.
                ScanFramingGuide(cropRect: cropRect, dimsSurroundings: false)
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

            // 크롭 화면은 시트가 아니라 이 ZStack의 한 겹으로 띄운다. fullScreenCover로
            // 띄우면 세이프에어리어 인셋이 0으로 전달돼 헤더가 상태바에 물린다.
            if let candidate = cropCandidate {
                PhotoCropView(
                    image: candidate.image,
                    onConfirm: { cropped in
                        cropCandidate = nil
                        pickedImage = cropped
                        Task { await viewModel.startScan(with: cropped) }
                    },
                    onReselect: {
                        cropCandidate = nil
                        isPickerPresented = true
                    },
                    onCancel: { cropCandidate = nil }
                )
                .transition(.opacity)
                .zIndex(1)
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
                    VStack(spacing: 12) {
                        PSButton(title: String(localized: String.LocalizationValue("ui.home.scanButton"))) {
                            // 화면에 그려진 가이드와 같은 값을 그대로 넘긴다.
                            let guideRect = cropRect
                            let container = screenSize
                            Task {
                                await viewModel.startScan(guideRect: guideRect, containerSize: container)
                            }
                        }

                        PSButton(
                            title: String(localized: String.LocalizationValue("ui.scan.pickPhotoButton")),
                            isProminent: false
                        ) {
                            isPickerPresented = true
                        }
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
        .photosPicker(isPresented: $isPickerPresented, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                // 같은 사진을 다시 골라도 onChange가 걸리도록 선택값을 비워 둔다.
                defer { pickerItem = nil }
                guard
                    let data = try? await newItem.loadTransferable(type: Data.self),
                    let image = UIImage(data: data)
                else { return }
                // 크롭 계산이 EXIF 회전에 걸리지 않도록 방향을 미리 픽셀에 굽는다.
                cropCandidate = CropCandidate(image: image.normalizedOrientation())
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

    /// 세이프에어리어를 무시한 전체 화면 크기를 재는 투명 레이어.
    /// 프리뷰 레이어와 같은 좌표계를 얻기 위한 것이라 `.ignoresSafeArea()`가 필수다 —
    /// 이게 빠지면 크롭 영역이 노치/홈바 높이만큼 위아래로 밀린다.
    private var screenMeasure: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { screenSize = proxy.size }
                .onChange(of: proxy.size) { _, newSize in screenSize = newSize }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// 사진 경로에서는 확정된 크롭 결과를 조준 창과 같은 자리에 같은 크기로 띄운다 —
    /// 크롭 에디터에서 본 그림과 스캔 중에 보이는 그림이 어긋나면 안 된다.
    @ViewBuilder
    private var background: some View {
        if let pickedImage {
            ZStack {
                Color.black
                Image(uiImage: pickedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cropRect.width, height: cropRect.height)
                    .clipShape(RoundedRectangle(cornerRadius: PSRadius.card))
                    .position(x: cropRect.midX, y: cropRect.midY)
            }
            .ignoresSafeArea()
        } else {
            CameraPreview(session: viewModel.camera.session)
                .ignoresSafeArea()
        }
    }
}

/// `fullScreenCover(item:)`에 넘기기 위한 래퍼. 매번 새 id를 받아, 같은 사진을
/// 다시 골라도 크롭 화면이 새로 뜬다.
private struct CropCandidate: Identifiable {
    let id = UUID()
    let image: UIImage
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
