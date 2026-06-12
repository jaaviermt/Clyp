//
//  ProfileView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct ProfileView: View {
    var refreshToken: UUID = UUID()
    var onLogout: () -> Void = {}

    @State private var watchedCount: Int = 0
    @State private var favoritesCount: Int = 0
    @State private var currentMood: Mood?
    @State private var userName: String?
    @State private var userEmail: String?
    @State private var welcomeLabel: String = "Profile"
    @State private var showDebugSheet: Bool = false
    @State private var showEditProfile: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                stats
                logoutSection
                    .padding(.top, AppSpacing.xl)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { refresh(consumeRegisterFlag: false) }
        .onChange(of: refreshToken) { _, _ in refresh(consumeRegisterFlag: true) }
        .sheet(isPresented: $showDebugSheet) {
            DebugConfigSheet()
        }
        .sheet(isPresented: $showEditProfile) {
            NavigationStack {
                ProfileEditView()
            }
        }
        .onChange(of: showEditProfile) { _, isShowing in
            if !isShowing {
                // Refresh profile data when edit sheet dismisses
                refresh(consumeRegisterFlag: false)
            }
        }
        .sensoryFeedback(.success, trigger: showDebugSheet)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(welcomeLabel)
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.ink.opacity(0.6))

            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
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
                
                Spacer()
                
                Button {
                    showEditProfile = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.clypOrange)
                        .padding(AppSpacing.sm)
                        .background(AppColors.silverScreen)
                        .clipShape(Circle())
                }
            }
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
                NavigationLink {
                    WatchedListView()
                } label: {
                    statCard(value: "\(watchedCount)", label: "Movies Watched")
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    FavoritesListView()
                } label: {
                    statCard(value: "\(favoritesCount)", label: "Favorites")
                }
                .buttonStyle(.plain)
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
            
            HStack(spacing: AppSpacing.xs) {
                Text(label)
                    .font(AppTypography.eyebrow)
                    .textCase(.uppercase)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.clypOrange)
            }
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

    private var logoutSection: some View {
        SecondaryCTAButton(title: "Log out") {
            performLogout()
        }
    }

    // MARK: - Actions

    private func performLogout() {
        LocalStorageService.shared.clearAll()
        onLogout()
    }

    /// `consumeRegisterFlag = false` is used by the initial `.onAppear`,
    /// which fires when MainTabView mounts (before the user has actually
    /// visited Profile). `true` is used by the refreshToken-driven refresh
    /// that fires only when the user selects the Profile tab.
    private func refresh(consumeRegisterFlag: Bool) {
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

        if userName != nil {
            if storage.didJustRegister {
                if consumeRegisterFlag {
                    storage.didJustRegister = false
                }
                welcomeLabel = "Welcome"
            } else {
                welcomeLabel = "Welcome back"
            }
        } else {
            welcomeLabel = "Profile"
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
