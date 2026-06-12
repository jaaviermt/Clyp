//
//  DiscoverView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct DiscoverView: View {
    @State private var viewModel: MoodViewModel
    @State private var selectedMood: Mood?
    @State private var showRecommendations = false

    init(viewModel: MoodViewModel? = nil) {
        let resolved = viewModel ?? (MockData.useMockData
            ? MoodViewModel(mockMoods: MockData.moods)
            : MoodViewModel())
        self._viewModel = State(initialValue: resolved)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            logoBar
            header
            content
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColors.cream.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.loadMoods() }
        .navigationDestination(isPresented: $showRecommendations) {
            if let mood = selectedMood {
                RecommendationsView(selectedMood: mood)
            }
        }
        .onChange(of: selectedMood) { _, newMood in
            if let mood = newMood {
                if let id = mood.id_mood {
                    LocalStorageService.shared.lastSelectedMoodId = id
                    let userId = LocalStorageService.shared.currentUserId ?? 1
                    LocalStorageService.shared.saveCheckin(MoodCheckin(
                        id_checkin: nil,
                        id_user: userId,
                        id_mood: id,
                        checkin_time: ISO8601DateFormatter().string(from: Date())
                    ))
                }
                showRecommendations = true
            }
        }
        .onChange(of: showRecommendations) { _, isShowing in
            if !isShowing { selectedMood = nil }
        }
    }

    // MARK: - Sections

    private var logoBar: some View {
        HStack(spacing: 0) {
            LogoView(font: AppTypography.displaySM, logoSize: 24)
            Spacer()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("How are you feeling?")
                .font(AppTypography.displayLG)
                .foregroundStyle(AppColors.ink)
            Text("Pick a mood to discover movies that match.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingState
        } else if let message = viewModel.errorMessage {
            errorState(message)
        } else {
            moodGrid
        }
    }

    private var loadingState: some View {
        VStack {
            Spacer()
            ProgressView().tint(AppColors.ink)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundStyle(AppColors.ink.opacity(0.25))
            Text("Something went wrong")
                .font(AppTypography.displaySM)
                .foregroundStyle(AppColors.ink)
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
                .multilineTextAlignment(.center)
            Button {
                Task { await viewModel.loadMoods() }
            } label: {
                Text("Try again")
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.clypOrange)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppSpacing.lg)
    }

    private var moodGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.md),
                    GridItem(.flexible(), spacing: AppSpacing.md)
                ],
                spacing: AppSpacing.md
            ) {
                ForEach(viewModel.moods, id: \.name) { mood in
                    Button {
                        withAnimation(AppAnimations.tap) {
                            selectedMood = mood
                        }
                    } label: {
                        MoodCard(
                            mood: mood,
                            isSelected: selectedMood?.name == mood.name
                        )
                    }
                    .buttonStyle(PressableScaleStyle())
                    .sensoryFeedback(.selection, trigger: selectedMood?.name == mood.name)
                }
            }
        }
    }
}

#Preview("Mock") {
    NavigationStack {
        DiscoverView(viewModel: MoodViewModel(mockMoods: MockData.moods))
    }
}

#Preview("Real API") {
    NavigationStack {
        DiscoverView(viewModel: MoodViewModel())
    }
}
