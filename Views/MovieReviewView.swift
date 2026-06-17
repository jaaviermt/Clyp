//
//  MovieReviewView.swift
//  Clyp
//
//  Created by xav on 12/06/26.
//

import SwiftUI

struct MovieReviewView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    
    @State private var reviewText: String = ""
    @State private var rating: Int = 0
    @State private var showDeleteConfirmation = false
    @FocusState private var isTextFieldFocused: Bool
    
    private var hasExistingReview: Bool {
        LocalStorageService.shared.review(for: movie.id_movie ?? 0) != nil
    }
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    movieHeader
                    ratingSection
                    reviewSection
                    
                    if hasExistingReview {
                        deleteButton
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.cream.ignoresSafeArea())
            .navigationTitle(hasExistingReview ? "Edit Review" : "Write Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.ink)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(hasExistingReview ? "Update" : "Save") {
                        saveReview()
                    }
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.clypOrange)
                    .disabled(reviewText.trimmingCharacters(in: .whitespaces).isEmpty || rating == 0)
                }
            }
            .onAppear {
                loadExistingReview()
            }
            .alert("Delete Review", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteReview()
                }
            } message: {
                Text("Are you sure you want to delete this review?")
            }
        }
    }
    
    // MARK: - Sections
    
    private var movieHeader: some View {
        HStack(spacing: AppSpacing.md) {
            PosterView(imageURLString: movie.image_url)
                .frame(width: 80, height: 120)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(movie.title)
                    .font(AppTypography.displaySM)
                    .foregroundStyle(AppColors.ink)
                    .lineLimit(2)
                
                if let year = movie.year {
                    Text(String(year))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.ink.opacity(0.6))
                }
            }
            
            Spacer()
        }
    }
    
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Rating")
                .font(AppTypography.label)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(AppAnimations.tap) {
                            rating = star
                        }
                    } label: {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundStyle(star <= rating ? AppColors.clypOrange : AppColors.ink.opacity(0.3))
                    }
                }
            }
        }
    }
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Review")
                .font(AppTypography.label)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            
            TextEditor(text: $reviewText)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink)
                .frame(minHeight: 150)
                .padding(AppSpacing.md)
                .background(AppColors.silverScreen)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                .focused($isTextFieldFocused)
            
            Text("\(reviewText.count) characters")
                .font(AppTypography.bodySM)
                .foregroundStyle(AppColors.ink.opacity(0.5))
        }
    }
    
    private var deleteButton: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Review")
                }
                .font(AppTypography.label)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(AppColors.heartbeat)
                .clipShape(Capsule())
            }
        }
        .padding(.top, AppSpacing.xl)
    }
    
    // MARK: - Actions
    
    private func loadExistingReview() {
        guard let id = movie.id_movie,
              let existing = LocalStorageService.shared.review(for: id) else {
            return
        }
        
        reviewText = existing.text
        rating = existing.rating
    }
    
    private func saveReview() {
        guard let movieId = movie.id_movie else { return }

        let text = reviewText.trimmingCharacters(in: .whitespaces)
        let value = rating

        // CREATE or UPDATE through the API (mirrors into the local cache):
        // `POST /review/save` when new, `PUT /review/update` when editing.
        Task { await RemoteSync.saveReview(movieId: movieId, text: text, rating: value) }

        dismiss()
    }

    private func deleteReview() {
        guard let movieId = movie.id_movie else { return }

        // DELETE through the API (`DELETE /review/delete/{id}`), then locally.
        Task { await RemoteSync.deleteReview(movieId: movieId) }

        dismiss()
    }
}

#Preview("New Review") {
    MovieReviewView(movie: MockData.movies[0])
}

#Preview("Existing Review") {
    let movie = MockData.movies[0]
    let _ = LocalStorageService.shared.saveReview(
        MovieReview(
            movieId: movie.id_movie ?? 0,
            text: "Amazing movie! Loved every minute of it.",
            rating: 5,
            createdAt: Date()
        )
    )
    MovieReviewView(movie: movie)
}
