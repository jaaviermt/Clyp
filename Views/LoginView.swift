//
//  LoginView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct LoginView: View {
    var onAuthenticated: () -> Void = {}

    @State private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""

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
                Text("Welcome back")
                    .font(AppTypography.displayLG)
                    .foregroundStyle(AppColors.ink)
                    .lineLimit(1)
                Text("Pick up where you left off.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
            }
            .multilineTextAlignment(.center)
        }
    }

    private var form: some View {
        VStack(spacing: AppSpacing.md) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .pillField()

            SecureField("Password", text: $password)
                .textContentType(.password)
                .pillField()
        }
    }

    private var cta: some View {
        VStack(spacing: AppSpacing.lg) {
            PrimaryCTAButton(title: "Log In") {
                // Real authentication via viewModel goes here.
                // Mock: persist a session locally so Profile can read it.
                let user = MockData.mockUser
                LocalStorageService.shared.currentUserId    = user.id_user
                LocalStorageService.shared.currentUserName  = user.name
                LocalStorageService.shared.currentUserEmail = user.email
                onAuthenticated()
            }

            NavigationLink {
                RegisterView(onAuthenticated: onAuthenticated)
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Text("Don't have an account?")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.ink.opacity(0.6))
                    Text("Sign up")
                        .font(AppTypography.label)
                        .foregroundStyle(AppColors.clypOrange)
                }
            }
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
    NavigationStack { LoginView() }
}
