//
//  CardImageSaver.swift
//  Potential Scanner
//
//  카드 아트보드를 이미지로 렌더링해 사진 앱에 저장. "추가" 권한만 있으면 되므로
//  전체 사진 라이브러리 접근이 아니라 addOnly 권한만 요청한다.
//

import Photos
import SwiftUI

enum CardImageSaver {
    enum SaveError: Error {
        case permissionDenied
        case renderFailed
    }

    @MainActor
    static func renderImage(content: CardArtboardContent, scale: CGFloat = 3) -> UIImage? {
        let renderer = ImageRenderer(content: CardArtboardView(content: content))
        renderer.scale = scale
        return renderer.uiImage
    }

    static func save(_ image: UIImage) async throws {
        let status = await requestAddOnlyAuthorization()
        guard status == .authorized || status == .limited else {
            throw SaveError.permissionDenied
        }
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }

    private static func requestAddOnlyAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }
}
