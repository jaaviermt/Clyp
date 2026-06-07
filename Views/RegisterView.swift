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
            TextField("Name", text: $name)
                .textInputAutocapitalization(.words)
                .textContentType(.name)
                .pillField()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .pillField()

            SecureField("Password", text: $password)
                .textContentType(.newPassword)
                .pillField()
        }
    }

    private var cta: some View {
        VStack(spacing: AppSpacing.lg) {
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
