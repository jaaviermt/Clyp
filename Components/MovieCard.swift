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

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            PosterView(imageURLString: movie.image_url)

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
    }
}
