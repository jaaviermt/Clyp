//
//  MovieCard.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct MovieCard: View {
    let movie: Movie
    var mood: Mood?

    /// Optional override. When nil, the card reads the rating
    /// from `LocalStorageService` (1...5). 0 / nil hides the row.
    var rating: Int? = nil

    @State private var isFavorite: Bool = false
    @State private var storedRating: Int = 0

    private var effectiveRating: Int {
        rating ?? storedRating
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ZStack(alignment: .topTrailing) {
                PosterView(imageURLString: movie.image_url)
                if isFavorite {
                    favoriteBadge
                        .padding(AppSpacing.sm)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Text(movie.title)
                .font(AppTypography.displaySM)
                .foregroundStyle(AppColors.ink)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: AppSpacing.sm) {
                if let mood {
                    MoodChip(mood: mood)
                }
                Spacer(minLength: 0)
                if effectiveRating > 0 {
                    RatingStars(rating: effectiveRating)
                }
            }
        }
        .onAppear {
            syncFavoriteState()
            syncRatingState()
        }
    }

    // MARK: - Badges

    private var favoriteBadge: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(AppColors.heartbeat)
            .padding(AppSpacing.xs)
            .background(AppColors.cream)
            .clipShape(Circle())
    }

    // MARK: - Sync

    private func syncFavoriteState() {
        guard let id = movie.id_movie else {
            isFavorite = false
            return
        }
        withAnimation(AppAnimations.favorites) {
            isFavorite = LocalStorageService.shared.isFavorite(id)
        }
    }

    private func syncRatingState() {
        guard let id = movie.id_movie else {
            storedRating = 0
            return
        }
        storedRating = LocalStorageService.shared.rating(for: id) ?? 0
    }
}
