//
//  FavoritesListView.swift
//  Clyp
//
//  Created by xav on 12/06/26.
//

import SwiftUI

struct FavoritesListView: View {
    @State private var favoriteIds: Set<Int> = []
    @Environment(\.dismiss) private var dismiss
    
    private var favoriteMovies: [Movie] {
        MockData.movies.filter {
            guard let id = $0.id_movie else { return false }
            return favoriteIds.contains(id)
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                if favoriteMovies.isEmpty {
                    emptyState
                } else {
                    movieGrid
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Favorites")
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
        .onAppear(perform: refresh)
    }
    
    // MARK: - Sections
    
    private var movieGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppSpacing.md),
                GridItem(.flexible(), spacing: AppSpacing.md)
            ],
            spacing: AppSpacing.lg
        ) {
            ForEach(favoriteMovies, id: \.id_movie) { movie in
                NavigationLink {
                    MovieDetailView(movie: movie)
                } label: {
                    MovieCard(
                        movie: movie,
                        mood: moodFor(movie)
                    )
                }
                .buttonStyle(PressableScaleStyle())
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            Image(systemName: "heart.slash")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AppColors.ink.opacity(0.25))
            
            VStack(spacing: AppSpacing.xs) {
                Text("No Favorites Yet")
                    .font(AppTypography.displayMD)
                    .foregroundStyle(AppColors.ink)
                
                Text("Tap the heart on a movie to save it here.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }
    
    // MARK: - Helpers
    
    private func moodFor(_ movie: Movie) -> Mood? {
        MockData.moods.first { $0.id_mood == movie.id_mood }
    }
    
    private func refresh() {
        favoriteIds = LocalStorageService.shared.favoriteMovieIds
    }
}

#Preview {
    NavigationStack {
        FavoritesListView()
    }
}
