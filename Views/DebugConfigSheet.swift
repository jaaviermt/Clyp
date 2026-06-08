//
//  DebugConfigSheet.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct DebugConfigSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var baseURLInput: String
    @State private var useMockData: Bool

    init() {
        self._baseURLInput = State(initialValue: APIService.baseURL?.absoluteString ?? "")
        self._useMockData = State(initialValue: MockData.useMockData)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header
                    urlSection
                    mockToggleSection
                    storageSection
                }
                .padding(AppSpacing.lg)
            }

            PrimaryCTAButton(title: "Save & Close") {
                save()
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Debug")
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            Text("Backend Config")
                .font(AppTypography.displayMD)
                .foregroundStyle(AppColors.ink)
        }
        .padding(.top, AppSpacing.md)
    }

    private var urlSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("API Base URL")
                .font(AppTypography.label)
                .foregroundStyle(AppColors.ink)

            TextField("https://xxxxx.share.zrok.io/API_Clyp/api", text: $baseURLInput)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(AppColors.silverScreen)
                .clipShape(Capsule())

            Text("Format: <host>/API_Clyp/api")
                .font(AppTypography.bodySM)
                .foregroundStyle(AppColors.ink.opacity(0.6))
        }
    }

    private var mockToggleSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Toggle(isOn: $useMockData) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Use mock data")
                        .font(AppTypography.label)
                        .foregroundStyle(AppColors.ink)
                    Text(useMockData
                         ? "Offline. App uses MockData."
                         : "Online. App hits the API.")
                        .font(AppTypography.bodySM)
                        .foregroundStyle(AppColors.ink.opacity(0.6))
                }
            }
            .tint(AppColors.clypOrange)
            .padding(AppSpacing.lg)
            .background(AppColors.silverScreen)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        }
    }

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Local Storage")
                .font(AppTypography.label)
                .foregroundStyle(AppColors.ink)

            Button {
                LocalStorageService.shared.clearAll()
            } label: {
                Text("Clear all local data")
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.heartbeat)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.silverScreen)
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableScaleStyle())

            Text("Wipes favorites, watched, ratings, current user, last mood.")
                .font(AppTypography.bodySM)
                .foregroundStyle(AppColors.ink.opacity(0.6))
        }
    }

    // MARK: - Persistence

    private func save() {
        let trimmed = baseURLInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            APIService.setBaseURL(trimmed)
        }
        MockData.useMockData = useMockData
        dismiss()
    }
}

#Preview {
    Text("Host").sheet(isPresented: .constant(true)) {
        DebugConfigSheet()
    }
}
