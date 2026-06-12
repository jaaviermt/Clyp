//
//  WatchedListView.swift
//  Clyp
//
//  Created by xav on 12/06/26.
//

import SwiftUI

struct WatchedListView: View {
    @State private var watchedIds: Set<Int> = []
    @Environment(\.dismiss) private var dismiss
    
    private var watchedMovies: [Movie] {
        MockData.movies.filter {
            guard let id = $0.id_movie else { return false }
            return watchedIds.contains(id)
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                if watchedMovies.isEmpty {
                    emptyState
                } else {
                    movieGrid
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Watched")
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
            ForEach(watchedMovies, id: \.id_movie) { movie in
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
            
            Image(systemName: "eye.slash")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AppColors.ink.opacity(0.25))
            
            VStack(spacing: AppSpacing.xs) {
                Text("No Watched Movies Yet")
                    .font(AppTypography.displayMD)
                    .foregroundStyle(AppColors.ink)
                
                Text("Mark a movie as watched to see it here.")
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
        watchedIds = LocalStorageService.shared.watchedMovieIds
    }
}

#Preview {
    NavigationStack {
        WatchedListView()
    }
}
