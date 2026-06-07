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
    var rating: Int?

    @State private var isFavorite: Bool = false

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
                if let rating {
                    RatingStars(rating: rating)
                }
            }
        }
        .onAppear(perform: syncFavoriteState)
    }

    // MARK: - Favorite badge

    private var favoriteBadge: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(AppColors.heartbeat)
            .padding(AppSpacing.xs)
            .background(AppColors.cream)
            .clipShape(Circle())
    }

    private func syncFavoriteState() {
        guard let id = movie.id_movie else {
            isFavorite = false
            return
        }
        withAnimation(AppAnimations.favorites) {
            isFavorite = LocalStorageService.shared.isFavorite(id)
        }
    }
}
