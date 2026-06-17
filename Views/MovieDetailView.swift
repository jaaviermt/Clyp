//
//  MovieDetailView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie

    @State private var isFavorite: Bool = false
    @State private var isWatched: Bool = false
    @State private var userRating: Int = 0
    @State private var showReviewSheet: Bool = false
    @State private var showFullReview: Bool = false
    @State private var hasReview: Bool = false

    /// Resolves the movie's mood from the API-backed shared catalog.
    private var resolvedMood: Mood? {
        AppData.shared.mood(id: movie.id_mood)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    poster
                    titleAndMeta
                    description
                    rating
                    reviewButton
                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            ctaBar
        }
        .background(AppColors.cream.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                favoriteButton
            }
        }
        .onAppear {
            syncFavoriteState()
            syncWatchedState()
            syncRatingState()
            syncReviewState()
        }
        .sheet(isPresented: $showReviewSheet) {
            ReviewSheet(movie: movie)
        }
        .onChange(of: showReviewSheet) { _, isShowing in
            if !isShowing {
                // Rating may have marked the movie as watched.
                syncRatingState()
                syncWatchedState()
            }
        }
        .sheet(isPresented: $showFullReview) {
            NavigationStack {
                MovieReviewView(movie: movie)
            }
        }
        .onChange(of: showFullReview) { _, isShowing in
            if !isShowing {
                // Writing a review may have marked the movie as watched.
                syncReviewState()
                syncRatingState()
                syncWatchedState()
            }
        }
    }

    // MARK: - Sections

    private var poster: some View {
        PosterView(imageURLString: movie.image_url)
            .frame(maxWidth: 220)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, AppSpacing.md)
    }

    private var titleAndMeta: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(movie.title)
                .font(AppTypography.displayLG)
                .foregroundStyle(AppColors.ink)

            HStack(spacing: AppSpacing.sm) {
                if let mood = resolvedMood {
                    MoodChip(mood: mood)
                }
                if let year = movie.year {
                    Text(String(year))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.ink.opacity(0.6))
                }
            }
        }
    }

    @ViewBuilder
    private var description: some View {
        if let text = movie.description {
            Text(text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var rating: some View {
        Button {
            showReviewSheet = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                RatingStars(rating: userRating, size: 18)
                Spacer(minLength: 0)
                Text(userRating > 0 ? "Edit" : "Rate")
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.clypOrange)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.clypOrange)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.silverScreen)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var reviewButton: some View {
        Button {
            showFullReview = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: hasReview ? "doc.text.fill" : "doc.text")
                    .font(.system(size: 16, weight: .medium))
                Text(hasReview ? "View Review" : "Write Review")
                    .font(AppTypography.body)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.clypOrange)
            }
            .foregroundStyle(AppColors.ink)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.silverScreen)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var ctaBar: some View {
        Group {
            if isWatched {
                SecondaryCTAButton(title: "Mark as Unwatched") {
                    toggleWatched()
                }
            } else {
                PrimaryCTAButton(title: "Mark as Watched") {
                    toggleWatched()
                }
            }
        }
        .animation(AppAnimations.tap, value: isWatched)
        .padding(AppSpacing.lg)
    }

    private func toggleWatched() {
        guard let id = movie.id_movie else { return }
        withAnimation(AppAnimations.favorites) {
            if isWatched {
                Task { await RemoteSync.unmarkWatched(movieId: id) }
                isWatched = false
            } else {
                Task { await RemoteSync.markWatched(movieId: id) }
                isWatched = true
            }
        }
    }

    // MARK: - Favorite

    private var favoriteButton: some View {
        Button(action: toggleFavorite) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(isFavorite ? AppColors.heartbeat : AppColors.ink)
                .scaleEffect(isFavorite ? 1.1 : 1.0)
        }
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }

    private func toggleFavorite() {
        guard let id = movie.id_movie else { return }
        let willFavorite = !isFavorite
        withAnimation(AppAnimations.favorites) {
            isFavorite = willFavorite

            // Automáticamente marcar como watched al dar favorito
            if willFavorite && !isWatched {
                isWatched = true
            }
        }
        Task {
            if willFavorite {
                await RemoteSync.addFavorite(movieId: id)
                if isWatched { await RemoteSync.markWatched(movieId: id) }
            } else {
                await RemoteSync.removeFavorite(movieId: id)
            }
        }
    }

    private func syncFavoriteState() {
        guard let id = movie.id_movie else {
            isFavorite = false
            return
        }
        isFavorite = LocalStorageService.shared.isFavorite(id)
    }

    private func syncWatchedState() {
        guard let id = movie.id_movie else {
            isWatched = false
            return
        }
        isWatched = LocalStorageService.shared.hasWatched(id)
    }

    private func syncRatingState() {
        guard let id = movie.id_movie else {
            userRating = 0
            return
        }
        userRating = LocalStorageService.shared.rating(for: id) ?? 0
    }
    
    private func syncReviewState() {
        guard let id = movie.id_movie else {
            hasReview = false
            return
        }
        // A written review (non-empty text), as opposed to a rating-only entry.
        let text = LocalStorageService.shared.review(for: id)?.text
        hasReview = !(text?.isEmpty ?? true)
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: MockData.movies[0])
    }
}
