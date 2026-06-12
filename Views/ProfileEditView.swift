//
//  ProfileEditView.swift
//  Clyp
//
//  Created by xav on 12/06/26.
//

import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var email: String
    @State private var hideWatched: Bool
    @State private var nameError: String?
    @State private var emailError: String?
    @State private var showDeleteConfirmation = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, email
    }

    init() {
        let storage = LocalStorageService.shared
        _name        = State(initialValue: storage.currentUserName ?? "")
        _email       = State(initialValue: storage.currentUserEmail ?? "")
        _hideWatched = State(initialValue: storage.hideWatchedMovies)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                form
                preferences
                dangerZone
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
                .font(AppTypography.label)
                .foregroundStyle(AppColors.clypOrange)
            }
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure? This action cannot be undone.")
        }
    }
    
    // MARK: - Sections
    
    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Profile Information")
                .font(AppTypography.displayMD)
                .foregroundStyle(AppColors.ink)
            Text("Update your account details")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
        }
        .padding(.top, AppSpacing.md)
    }
    
    private var form: some View {
        VStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Name")
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
                
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)
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
                Text("Email")
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.done)
                    .onSubmit { saveChanges() }
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
        }
    }
    
    private var preferences: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Preferences")
                .font(AppTypography.displaySM)
                .foregroundStyle(AppColors.ink)

            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Hide watched movies")
                        .font(AppTypography.label)
                        .foregroundStyle(AppColors.ink)
                    Text("Already-watched titles won't appear in your recommendations.")
                        .font(AppTypography.bodySM)
                        .foregroundStyle(AppColors.ink.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppSpacing.lg)

                Toggle("", isOn: $hideWatched)
                    .labelsHidden()
                    .tint(AppColors.clypOrange)
                    .animation(AppAnimations.tap, value: hideWatched)
            }
            .padding(AppSpacing.lg)
            .background(AppColors.silverScreen)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Danger Zone")
                .font(AppTypography.displaySM)
                .foregroundStyle(AppColors.heartbeat)
            
            Text("Deleting your account is permanent and cannot be undone.")
                .font(AppTypography.bodySM)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            
            Button {
                showDeleteConfirmation = true
            } label: {
                Text("Delete Account")
                    .font(AppTypography.label)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.heartbeat)
                    .clipShape(Capsule())
            }
        }
        .padding(.top, AppSpacing.xl)
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
    
    // MARK: - Actions
    
    private func saveChanges() {
        // Validate
        withAnimation(AppAnimations.tap) {
            nameError = AuthValidation.nameError(for: name)
            emailError = AuthValidation.emailError(for: email)
        }
        
        guard nameError == nil, emailError == nil else { return }
        
        // UPDATE operation - Save to storage
        let storage = LocalStorageService.shared
        storage.currentUserName    = name.trimmingCharacters(in: .whitespaces)
        storage.currentUserEmail   = email.trimmingCharacters(in: .whitespaces)
        storage.hideWatchedMovies  = hideWatched

        // TODO: When API is ready, call updateProfile endpoint
        // await viewModel.updateProfile(name: name, email: email)
        
        focusedField = nil
        dismiss()
    }
    
    private func deleteAccount() {
        // DELETE operation - Clear all user data
        LocalStorageService.shared.clearAll()
        
        // TODO: When API is ready, call deleteAccount endpoint
        // await viewModel.deleteAccount()
        
        // Navigate back to auth screen
        dismiss()
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
    NavigationStack {
        ProfileEditView()
    }
}
