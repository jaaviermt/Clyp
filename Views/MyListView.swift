//
//  MyListView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct MyListView: View {
    var refreshToken: UUID = UUID()
    
    @State private var favoriteIds: Set<Int> = []
    @State private var watchedIds: Set<Int> = []

    private var favoriteMovies: [Movie] {
        AppData.shared.movies.filter {
            guard let id = $0.id_movie else { return false }
            return favoriteIds.contains(id)
        }
    }

    private var watchedMovies: [Movie] {
        AppData.shared.movies.filter {
            guard let id = $0.id_movie else { return false }
            return watchedIds.contains(id)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header

                section(
                    title: "Favorites",
                    movies: favoriteMovies,
                    emptyMessage: "Tap the heart on a movie to save it here."
                )

                section(
                    title: "Watched",
                    movies: watchedMovies,
                    emptyMessage: "Mark a movie as watched to see it here."
                )
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: refresh)
        .onChange(of: refreshToken) { _, _ in refresh() }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("My List")
                .font(AppTypography.displayLG)
                .foregroundStyle(AppColors.ink)
            Text("Your saved and watched movies.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
        }
        .padding(.top, AppSpacing.md)
    }

    @ViewBuilder
    private func section(title: String, movies: [Movie], emptyMessage: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTypography.displayMD)
                .foregroundStyle(AppColors.ink)

            if movies.isEmpty {
                emptyRow(message: emptyMessage)
            } else {
                movieRow(movies: movies)
            }
        }
    }

    private func movieRow(movies: [Movie]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                ForEach(movies, id: \.id_movie) { movie in
                    NavigationLink {
                        MovieDetailView(movie: movie)
                    } label: {
                        MovieCard(
                            movie: movie,
                            mood: moodFor(movie)
                        )
                        .frame(width: 160)
                    }
                    .buttonStyle(PressableScaleStyle())
                }
            }
            .padding(.trailing, AppSpacing.xl)
        }
        .mask(trailingFadeMask)
    }

    private var trailingFadeMask: some View {
        HStack(spacing: 0) {
            Rectangle()
            LinearGradient(
                colors: [.black, .black.opacity(0)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 32)
        }
    }

    private func emptyRow(message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(AppColors.ink.opacity(0.25))
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, AppSpacing.lg)
    }

    // MARK: - Helpers

    private func moodFor(_ movie: Movie) -> Mood? {
        AppData.shared.moods.first { $0.id_mood == movie.id_mood }
    }

    private func refresh() {
        favoriteIds = LocalStorageService.shared.favoriteMovieIds
        watchedIds  = LocalStorageService.shared.watchedMovieIds
    }
}

#Preview {
    NavigationStack { MyListView() }
}
