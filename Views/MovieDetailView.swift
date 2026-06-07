//
//  MovieDetailView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                PosterView(imageURLString: movie.image_url)
                    .frame(maxWidth: 220)
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(movie.title)
                        .font(AppTypography.displayLG)
                        .foregroundStyle(AppColors.ink)
                    if let year = movie.year {
                        Text(String(year))
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.ink.opacity(0.6))
                    }
                }

                if let description = movie.description {
                    Text(description)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.ink)
                }
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColors.cream.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: MockData.movies[0])
    }
}
