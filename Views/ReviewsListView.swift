//
//  ReviewsListView.swift
//  Clyp
//

import SwiftUI

struct ReviewsListView: View {
    @State private var reviews: [MovieReview] = []
    @State private var pendingDelete: MovieReview?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                if reviews.isEmpty {
                    emptyState
                } else {
                    ForEach(reviews) { review in
                        reviewCard(review)
                    }
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.ink.opacity(0.4))
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .task { await refresh() }
        .alert("Delete Review", isPresented: deleteAlertBinding) {
            Button("Cancel", role: .cancel) { pendingDelete = nil }
            Button("Delete", role: .destructive) {
                if let review = pendingDelete { delete(review) }
            }
        } message: {
            Text("Are you sure you want to delete this review?")
        }
    }

    // MARK: - Cards

    private func reviewCard(_ review: MovieReview) -> some View {
        let movie = AppData.shared.movies.first { $0.id_movie == review.movieId }

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                PosterView(imageURLString: movie?.image_url)
                    .frame(width: 56, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(movie?.title ?? "Unknown movie")
                        .font(AppTypography.label)
                        .foregroundStyle(AppColors.ink)
                        .lineLimit(2)

                    RatingStars(rating: review.rating, size: 14)
                }

                Spacer(minLength: 0)

                Button {
                    pendingDelete = review
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.heartbeat)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete review")
            }

            Text(review.text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.silverScreen)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "text.bubble")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AppColors.ink.opacity(0.25))

            VStack(spacing: AppSpacing.xs) {
                Text("No Reviews Yet")
                    .font(AppTypography.displayMD)
                    .foregroundStyle(AppColors.ink)

                Text("Write a review on a movie to see it here.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 400)
        .padding(AppSpacing.xl)
    }

    // MARK: - Data

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )
    }

    /// Pulls the latest reviews from the API into the local cache, then shows
    /// the written ones (those with text) most-recent first.
    private func refresh() async {
        await RemoteSync.pullCurrentUser()
        load()
    }

    private func load() {
        reviews = LocalStorageService.shared.allReviews
            .filter { !$0.text.isEmpty }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func delete(_ review: MovieReview) {
        pendingDelete = nil
        // Optimistic removal; the API delete + local cache update run in the task.
        reviews.removeAll { $0.movieId == review.movieId }
        Task { await RemoteSync.deleteReview(movieId: review.movieId) }
    }
}

#Preview {
    NavigationStack { ReviewsListView() }
}
