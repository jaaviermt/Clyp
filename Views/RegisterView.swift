//
//  RegisterView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct RegisterView: View {
    var onAuthenticated: () -> Void = {}

    @State private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var nameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: AppSpacing.xxxl)

                    VStack(spacing: AppSpacing.xxxl) {
                        brand
                        form
                        cta
                    }

                    Spacer(minLength: AppSpacing.xxxl)
                }
                .padding(.horizontal, AppSpacing.xl)
                .frame(minHeight: geo.size.height)
                .frame(maxWidth: .infinity)
            }
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Sections

    private var brand: some View {
        VStack(spacing: AppSpacing.lg) {
            LogoView(font: AppTypography.displayMD, logoSize: 40)

            VStack(spacing: AppSpacing.xs) {
                Text("Create account")
                    .font(AppTypography.displayLG)
                    .foregroundStyle(AppColors.ink)
                    .lineLimit(1)
                Text("Start matching movies to your soul.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var form: some View {
        VStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)
                    .textContentType(.name)
                    .pillField()
                    .onChange(of: name) { _, _ in
                        if nameError != nil {
                            withAnimation(AppAnimations.tap) { nameError = nil }
                        }
                    }

                if let nameError {
                    errorLabel(nameError)
                }
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
                    .pillField()
                    .onChange(of: email) { _, _ in
                        if emailError != nil {
                            withAnimation(AppAnimations.tap) { emailError = nil }
                        }
                    }

                if let emailError {
                    errorLabel(emailError)
                }
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .pillField()
                    .onChange(of: password) { _, _ in
                        if passwordError != nil {
                            withAnimation(AppAnimations.tap) { passwordError = nil }
                        }
                    }

                if let passwordError {
                    errorLabel(passwordError)
                }
            }
        }
    }

    private var cta: some View {
        VStack(spacing: AppSpacing.lg) {
            PrimaryCTAButton(title: "Create Account") {
                attemptRegister()
            }

            Button {
                dismiss()
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Text("Already have an account?")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.ink.opacity(0.6))
                    Text("Log in")
                        .font(AppTypography.label)
                        .foregroundStyle(AppColors.clypOrange)
                }
            }
        }
    }

    // MARK: - Helpers

    private func errorLabel(_ message: String) -> some View {
        Text(message)
            .font(AppTypography.bodySM)
            .foregroundStyle(AppColors.heartbeat)
            .padding(.leading, AppSpacing.lg)
            .transition(.opacity)
    }

    private func attemptRegister() {
        withAnimation(AppAnimations.tap) {
            nameError     = AuthValidation.nameError(for: name)
            emailError    = AuthValidation.emailError(for: email)
            passwordError = AuthValidation.passwordError(for: password)
        }

        guard nameError == nil, emailError == nil, passwordError == nil else { return }

        // Real registration via viewModel goes here.
        // Mock: store the form values, falling back to mockUser for safety.
        let storage = LocalStorageService.shared
        storage.currentUserId    = MockData.mockUser.id_user
        storage.currentUserName  = name.trimmingCharacters(in: .whitespaces)
        storage.currentUserEmail = email.trimmingCharacters(in: .whitespaces)
        onAuthenticated()
    }
}

private extension View {
    func pillField() -> some View {
        self
            .font(AppTypography.body)
            .foregroundStyle(AppColors.ink)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.silverScreen)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack { RegisterView() }
}
