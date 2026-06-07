//
//  MovieDetailView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie

    /// Mock-mode mood lookup. When the API is live this should come
    /// from a shared store (e.g. injected via environment or a VM).
    private var resolvedMood: Mood? {
        MockData.moods.first { $0.id_mood == movie.id_mood }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    poster
                    titleAndMeta
                    description
                    rating
                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            ctaBar
        }
        .background(AppColors.cream.ignoresSafeArea())
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
        RatingStars(rating: 0, size: 18)
    }

    private var ctaBar: some View {
        PrimaryCTAButton(title: "Mark as Watched") {
            // TODO: integrate with POST /watched/save
            // Body: { "id_user": <session>, "id_movie": movie.id_movie }
        }
        .padding(AppSpacing.lg)
    }
}

#Preview("Happy") {
    NavigationStack {
        MovieDetailView(movie: MockData.movies[0])
    }
}

#Preview("Romantic") {
    NavigationStack {
        MovieDetailView(movie: MockData.movies[3])
    }
}
