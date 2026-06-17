//
//  ReviewSheet.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct ReviewSheet: View {
    let movie: Movie

    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int

    init(movie: Movie) {
        self.movie = movie
        let stored: Int = {
            guard let id = movie.id_movie else { return 0 }
            return LocalStorageService.shared.rating(for: id) ?? 0
        }()
        self._rating = State(initialValue: stored)
    }

    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            header
            ratingPicker
            Spacer()
            actions
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Rate this movie")
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            Text(movie.title)
                .font(AppTypography.displayMD)
                .foregroundStyle(AppColors.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.top, AppSpacing.lg)
    }

    private var ratingPicker: some View {
        RatingStars(rating: rating, size: 36) { tapped in
            withAnimation(AppAnimations.favorites) {
                rating = (rating == tapped) ? 0 : tapped
            }
        }
    }

    private var actions: some View {
        VStack(spacing: AppSpacing.md) {
            PrimaryCTAButton(title: "Save Rating") {
                save()
            }
            .disabled(rating == 0)
            .opacity(rating == 0 ? 0.4 : 1)
            .animation(AppAnimations.tap, value: rating)

            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
            }
        }
    }

    // MARK: - Persistence

    private func save() {
        guard let id = movie.id_movie else { return }

        // Rating a movie implies you watched it (you can't rate what you
        // haven't seen). The rating is stored as a review, keeping any text it
        // already had; saveReview also marks the movie as watched.
        let value = rating
        let existingText = LocalStorageService.shared.review(for: id)?.text
        LocalStorageService.shared.setRating(value, for: id)
        Task { await RemoteSync.saveReview(movieId: id, text: existingText, rating: value) }
        dismiss()
    }
}

#Preview {
    Text("Host")
        .sheet(isPresented: .constant(true)) {
            ReviewSheet(movie: MockData.movies[0])
        }
}
