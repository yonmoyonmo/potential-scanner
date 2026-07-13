//
//  PSConfirmModal.swift
//  Potential Scanner
//
//  시스템 .alert()는 UIKit이 그려서 커스텀 폰트가 안 먹는다(네비게이션 타이틀과 동일한 문제).
//  직접 그린 SwiftUI 모달이라 PSTypography 폰트가 그대로 적용된다.
//

import SwiftUI

/// 딤 배경 + 카드 패널 + 취소/확인 버튼 두 줄이라는 공통 뼈대. 가운데 내용(middle)만 갈아끼워
/// 확인 모달과 텍스트 입력 모달이 이 위에서 각자 조립된다.
private struct PSModalPanel<Middle: View>: View {
    let title: String
    let confirmTitle: String
    let cancelTitle: String
    let confirmColor: Color
    @ViewBuilder let middle: Middle
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(PSTypography.pageTitle)
                .foregroundStyle(PSColor.ink)
                .multilineTextAlignment(.center)

            middle

            HStack(spacing: 12) {
                modalButton(cancelTitle, background: PSColor.cardFill, textColor: PSColor.ink, action: onCancel)
                modalButton(confirmTitle, background: confirmColor, textColor: .white, action: onConfirm)
            }
        }
        .padding(24)
        .frame(maxWidth: 320)
        .background(RoundedRectangle(cornerRadius: PSRadius.card).fill(PSColor.cloud))
        .psHardShadow(radius: PSRadius.card)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
        .zIndex(1)
    }

    private func modalButton(
        _ title: String,
        background: Color,
        textColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(PSTypography.body)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: PSRadius.card).fill(background))
        }
        .buttonStyle(.plain)
    }
}

private struct PSModalDimBackground: View {
    let onTap: () -> Void

    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture(perform: onTap)
    }
}

private struct PSConfirmModal: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                PSModalDimBackground { isPresented = false }

                PSModalPanel(
                    title: title,
                    confirmTitle: confirmTitle,
                    cancelTitle: cancelTitle,
                    confirmColor: PSColor.signalMagenta,
                    middle: {
                        Text(message)
                            .font(PSTypography.body)
                            .foregroundStyle(PSColor.muted)
                            .multilineTextAlignment(.center)
                    },
                    onCancel: { isPresented = false },
                    onConfirm: {
                        isPresented = false
                        onConfirm()
                    }
                )
            }
        }
        .animation(.easeOut(duration: 0.2), value: isPresented)
    }
}

private struct PSTextPromptModal: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var text: String
    let title: String
    let placeholder: String
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                PSModalDimBackground { isPresented = false }

                PSModalPanel(
                    title: title,
                    confirmTitle: confirmTitle,
                    cancelTitle: cancelTitle,
                    confirmColor: PSColor.skyStrong,
                    middle: {
                        TextField(placeholder, text: $text)
                            .font(PSTypography.body)
                            .foregroundStyle(PSColor.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: PSRadius.card).fill(PSColor.cardFill))
                    },
                    onCancel: { isPresented = false },
                    onConfirm: {
                        isPresented = false
                        onConfirm()
                    }
                )
            }
        }
        .animation(.easeOut(duration: 0.2), value: isPresented)
    }
}

extension View {
    /// 커스텀 폰트가 먹는 확인 모달. 제목/메시지/버튼 문구를 전부 로컬라이즈드 문자열로 넘긴다.
    func psConfirmModal(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String,
        cancelTitle: String = String(localized: String.LocalizationValue("ui.confirm.cancel")),
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(
            PSConfirmModal(
                isPresented: isPresented,
                title: title,
                message: message,
                confirmTitle: confirmTitle,
                cancelTitle: cancelTitle,
                onConfirm: onConfirm
            )
        )
    }

    /// 커스텀 폰트가 먹는 텍스트 입력 모달 (이름 입력/수정 등에 사용).
    func psTextPromptModal(
        isPresented: Binding<Bool>,
        text: Binding<String>,
        title: String,
        placeholder: String,
        confirmTitle: String,
        cancelTitle: String = String(localized: String.LocalizationValue("ui.confirm.cancel")),
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(
            PSTextPromptModal(
                isPresented: isPresented,
                text: text,
                title: title,
                placeholder: placeholder,
                confirmTitle: confirmTitle,
                cancelTitle: cancelTitle,
                onConfirm: onConfirm
            )
        )
    }
}
