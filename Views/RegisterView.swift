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
                Text("Create account")
                    .font(AppTypography.displayMD)
                    .foregroundStyle(AppColors.ink)
                Text("Start matching movies to your soul.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
            }
        }
        .padding(.top, AppSpacing.xl)
    }

    private var fields: some View {
        VStack(spacing: AppSpacing.md) {
            TextField("Name", text: $name)
                .textInputAutocapitalization(.words)
                .underlinedField()
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
            PrimaryCTAButton(title: "Create Account") {
                // Real registration via viewModel goes here.
                onAuthenticated()
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
    NavigationStack { RegisterView() }
}
