//
//  ProfileView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct ProfileView: View {
    var onLogout: () -> Void = {}

    @State private var watchedCount: Int = 0
    @State private var favoritesCount: Int = 0
    @State private var currentMood: Mood?
    @State private var userName: String?
    @State private var userEmail: String?
    @State private var showDebugSheet: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                stats
                logoutButton
                    .padding(.top, AppSpacing.xl)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: refresh)
        .sheet(isPresented: $showDebugSheet) {
            DebugConfigSheet()
        }
        .sensoryFeedback(.success, trigger: showDebugSheet)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(userName != nil ? "Welcome back" : "Profile")
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.ink.opacity(0.6))

            Text(userName ?? "Your Profile")
                .font(AppTypography.displayLG)
                .foregroundStyle(AppColors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(userEmail ?? "Your taste at a glance.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.top, AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 1.5) {
            showDebugSheet = true
        }
    }

    private var stats: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                statCard(value: "\(watchedCount)",   label: "Movies Watched")
                statCard(value: "\(favoritesCount)", label: "Favorites")
            }
            currentMoodCard
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(value)
                .font(AppTypography.displayXL)
                .foregroundStyle(AppColors.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.ink.opacity(0.6))
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.silverScreen)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }

    private var currentMoodCard: some View {
        let foreground = currentMood?.foregroundOnColor ?? AppColors.ink
        let background = currentMood?.color ?? AppColors.silverScreen

        return VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(currentMood?.name ?? "None yet")
                .font(AppTypography.displayXL)
                .foregroundStyle(foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("Current Mood")
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(foreground.opacity(0.7))
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button(action: performLogout) {
            Text("Log out")
                .font(AppTypography.label)
                .foregroundStyle(AppColors.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(AppColors.silverScreen)
                .clipShape(Capsule())
        }
        .buttonStyle(PressableScaleStyle())
    }

    private func performLogout() {
        LocalStorageService.shared.clearAll()
        onLogout()
    }

    // MARK: - Refresh

    private func refresh() {
        let storage = LocalStorageService.shared
        watchedCount   = storage.watchedMovieIds.count
        favoritesCount = storage.favoriteMovieIds.count
        userName       = storage.currentUserName
        userEmail      = storage.currentUserEmail

        if let moodId = storage.lastSelectedMoodId {
            currentMood = MockData.moods.first { $0.id_mood == moodId }
        } else {
            currentMood = nil
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
