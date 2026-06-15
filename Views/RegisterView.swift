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
    @State private var passwordVisible: Bool = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, email, password
    }

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
            .scrollDismissesKeyboard(.interactively)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.clypOrange)
            }
        }
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
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
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
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
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
                HStack(spacing: AppSpacing.sm) {
                    Group {
                        if passwordVisible {
                            TextField("Password", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("Password", text: $password)
                        }
                    }
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit { attemptRegister() }
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.ink)

                    Button {
                        passwordVisible.toggle()
                    } label: {
                        Image(systemName: passwordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColors.ink.opacity(0.5))
                    }
                    .accessibilityLabel(passwordVisible ? "Hide password" : "Show password")
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(AppColors.silverScreen)
                .clipShape(Capsule())
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
            if let serverError = viewModel.errorMessage {
                errorLabel(serverError)
            }

            PrimaryCTAButton(title: viewModel.isLoading ? "Creating…" : "Create Account") {
                attemptRegister()
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.6 : 1)

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
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.heartbeat)
            Text(message)
                .font(AppTypography.bodySM)
                .foregroundStyle(AppColors.ink.opacity(0.8))
        }
        .padding(.leading, AppSpacing.lg)
        .transition(.opacity)
    }

    private func attemptRegister() {
        guard !viewModel.isLoading else { return }
        withAnimation(AppAnimations.tap) {
            nameError     = AuthValidation.nameError(for: name)
            emailError    = AuthValidation.emailError(for: email)
            passwordError = AuthValidation.passwordError(for: password)
        }

        guard nameError == nil, emailError == nil, passwordError == nil else { return }

        focusedField = nil

        Task {
            let ok = await viewModel.register(
                name: name.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            if ok { onAuthenticated() }
        }
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
