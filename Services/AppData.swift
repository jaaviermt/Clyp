//
//  AppData.swift
//  Clyp
//
//  App-wide catalog (moods + movies) backed by the API.
//

import Foundation
import Observation

/// Shared, in-memory catalog loaded once from the backend.
///
/// Views read `AppData.shared.moods` / `.movies` directly. Because these
/// are `@Observable` properties, any read inside a SwiftUI `body` is tracked
/// and the view re-renders when the catalog finishes loading.
///
/// Falls back to `MockData` when mock mode is on or the network fails.
@Observable
@MainActor
final class AppData {
    static let shared = AppData()

    private(set) var moods: [Mood] = []
    private(set) var movies: [Movie] = []
    private(set) var genres: [Genre] = []
    private(set) var isLoading = false

    private let apiService: APIService
    private var hasLoaded = false

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    /// Loads the catalog from the API. Safe to call multiple times;
    /// only the first successful load does work unless `force` is set.
    func load(force: Bool = false) async {
        if hasLoaded && !force { return }

        if MockData.useMockData {
            moods = MockData.moods
            movies = MockData.movies
            genres = MockData.genres
            hasLoaded = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        async let fetchedMoods: [Mood] = apiService.fetch(.getAllMoods)
        async let fetchedMovies: [Movie] = apiService.fetch(.getAllMovies)
        async let fetchedGenres: [Genre] = apiService.fetch(.getAllGenres)

        // Catalog comes strictly from the API. On failure the lists stay
        // empty (views render their empty states) — no mock data at runtime.
        if let m = try? await fetchedMoods { moods = m }
        if let mv = try? await fetchedMovies { movies = mv }
        if let g = try? await fetchedGenres { genres = g }

        // Only consider the load "done" once we actually have data, so a
        // transient failure (e.g. Render cold start) can be retried.
        hasLoaded = !moods.isEmpty && !movies.isEmpty
    }

    // MARK: - Lookups

    func mood(id: Int?) -> Mood? {
        guard let id else { return nil }
        return moods.first { $0.id_mood == id }
    }

    func movies(forMood moodId: Int) -> [Movie] {
        movies.filter { $0.id_mood == moodId }
    }

    func genre(id: Int?) -> Genre? {
        guard let id else { return nil }
        return genres.first { $0.id_genre == id }
    }

    // MARK: - Catalog mutation (used by CatalogViewModel)
    //
    // These keep the in-memory catalog in sync after a create/update/delete.
    // `CatalogViewModel` calls the API first; these apply the result (or the
    // optimistic local copy when the API is unavailable). Because the arrays
    // are `@Observable`, every view reading `AppData.shared.*` updates at once.

    func upsertMovie(_ movie: Movie) {
        if let id = movie.id_movie, let idx = movies.firstIndex(where: { $0.id_movie == id }) {
            movies[idx] = movie
        } else {
            movies.append(movie)
        }
    }

    func removeMovie(id: Int) { movies.removeAll { $0.id_movie == id } }

    func upsertMood(_ mood: Mood) {
        if let id = mood.id_mood, let idx = moods.firstIndex(where: { $0.id_mood == id }) {
            moods[idx] = mood
        } else {
            moods.append(mood)
        }
    }

    func removeMood(id: Int) { moods.removeAll { $0.id_mood == id } }

    func upsertGenre(_ genre: Genre) {
        if let id = genre.id_genre, let idx = genres.firstIndex(where: { $0.id_genre == id }) {
            genres[idx] = genre
        } else {
            genres.append(genre)
        }
    }

    func removeGenre(id: Int) { genres.removeAll { $0.id_genre == id } }

    /// Next synthetic id for an optimistic local insert (offline fallback),
    /// so the new row has a stable identity until the server assigns the real one.
    func nextLocalMovieId() -> Int { (movies.compactMap(\.id_movie).max() ?? 0) + 1 }
    func nextLocalMoodId()  -> Int { (moods.compactMap(\.id_mood).max() ?? 0) + 1 }
    func nextLocalGenreId() -> Int { (genres.compactMap(\.id_genre).max() ?? 0) + 1 }
}
