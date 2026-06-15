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
            hasLoaded = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        async let fetchedMoods: [Mood] = apiService.fetch(.getAllMoods)
        async let fetchedMovies: [Movie] = apiService.fetch(.getAllMovies)

        // Catalog comes strictly from the API. On failure the lists stay
        // empty (views render their empty states) — no mock data at runtime.
        if let m = try? await fetchedMoods { moods = m }
        if let mv = try? await fetchedMovies { movies = mv }

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
}
