//
//  RecommendationsView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct RecommendationsView: View {
    let selectedMood: Mood

    private var filteredMovies: [Movie] {
        guard let moodId = selectedMood.id_mood else { return [] }
        let movies = AppData.shared.movies.filter { $0.id_mood == moodId }
        guard LocalStorageService.shared.hideWatchedMovies else { return movies }
        let watched = LocalStorageService.shared.watchedMovieIds
        return movies.filter { movie in
            guard let id = movie.id_movie else { return true }
            return !watched.contains(id)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                content
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColors.cream.ignoresSafeArea())
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Recommendations")
                .font(AppTypography.displayLG)
                .foregroundStyle(AppColors.ink)
            (
                Text("Movies for your ")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
                + Text(selectedMood.name)
                    .font(AppTypography.label)
                    .foregroundStyle(selectedMood.color)
                + Text(" mood")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
            )
        }
        .padding(.top, AppSpacing.md)
    }

    @ViewBuilder
    private var content: some View {
        if filteredMovies.isEmpty {
            emptyState
        } else {
            moviesGrid
        }
    }

    private var moviesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppSpacing.md),
                GridItem(.flexible(), spacing: AppSpacing.md)
            ],
            spacing: AppSpacing.lg
        ) {
            ForEach(filteredMovies, id: \.id_movie) { movie in
                NavigationLink {
                    MovieDetailView(movie: movie)
                } label: {
                    MovieCard(movie: movie, mood: selectedMood)
                }
                .buttonStyle(PressableScaleStyle())
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundStyle(AppColors.ink.opacity(0.25))
            Text("No movies yet")
                .font(AppTypography.displaySM)
                .foregroundStyle(AppColors.ink)
            Text("We couldn't find movies that match this mood.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xxl)
    }
}

#Preview("Has movies") {
    NavigationStack {
        RecommendationsView(
            selectedMood: Mood(id_mood: 1, name: "Happy", description: nil)
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        RecommendationsView(
            selectedMood: Mood(id_mood: 999, name: "Unknown", description: nil)
        )
    }
}
