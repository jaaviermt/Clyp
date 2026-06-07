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
        VStack(alignment: .leading, spacing: AppSpacing.xxl) {
            header
            fields
            Spacer(minLength: AppSpacing.xl)
            footer
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColors.cream.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            LogoView(font: AppTypography.displayLG, dotSize: 10)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Welcome back")
                    .font(AppTypography.displayMD)
                    .foregroundStyle(AppColors.ink)
                Text("Movies that match your soul.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
            }
        }
        .padding(.top, AppSpacing.xl)
    }

    private var fields: some View {
        VStack(spacing: AppSpacing.md) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .underlinedField()
            SecureField("Password", text: $password)
                .underlinedField()
        }
    }

    private var footer: some View {
        VStack(spacing: AppSpacing.md) {
            PrimaryCTAButton(title: "Log In") {
                // Real authentication via viewModel goes here.
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
    func underlinedField() -> some View {
        self
            .font(AppTypography.body)
            .foregroundStyle(AppColors.ink)
            .padding(.vertical, AppSpacing.sm)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(AppColors.ink.opacity(0.2))
            }
    }
}

#Preview {
    NavigationStack { LoginView() }
}
