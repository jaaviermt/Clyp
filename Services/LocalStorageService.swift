//
//  LocalStorageService.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

nonisolated final class LocalStorageService: @unchecked Sendable {
    static let shared = LocalStorageService()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    private enum Key {
        static let favoriteMovieIds   = "clyp.local.favoriteMovieIds"
        static let watchedMovieIds    = "clyp.local.watchedMovieIds"
        static let lastSelectedMoodId = "clyp.local.lastSelectedMoodId"
        static let movieRatings       = "clyp.local.movieRatings"
        static let movieReviews       = "clyp.local.movieReviews"
        static let currentUserId      = "clyp.local.currentUserId"
        static let currentUserName    = "clyp.local.currentUserName"
        static let currentUserEmail   = "clyp.local.currentUserEmail"
        static let didJustRegister    = "clyp.local.didJustRegister"
        static let hideWatchedMovies  = "clyp.local.hideWatchedMovies"
    }

    // MARK: - Favorites

    var favoriteMovieIds: Set<Int> {
        Set(defaults.array(forKey: Key.favoriteMovieIds) as? [Int] ?? [])
    }

    func addFavorite(_ movieId: Int) {
        var current = favoriteMovieIds
        current.insert(movieId)
        defaults.set(Array(current), forKey: Key.favoriteMovieIds)
    }

    func removeFavorite(_ movieId: Int) {
        var current = favoriteMovieIds
        current.remove(movieId)
        defaults.set(Array(current), forKey: Key.favoriteMovieIds)
    }

    func isFavorite(_ movieId: Int) -> Bool {
        favoriteMovieIds.contains(movieId)
    }

    func toggleFavorite(_ movieId: Int) {
        if isFavorite(movieId) {
            removeFavorite(movieId)
        } else {
            addFavorite(movieId)
        }
    }

    // MARK: - Watched

    var watchedMovieIds: Set<Int> {
        Set(defaults.array(forKey: Key.watchedMovieIds) as? [Int] ?? [])
    }

    func markWatched(_ movieId: Int) {
        var current = watchedMovieIds
        current.insert(movieId)
        defaults.set(Array(current), forKey: Key.watchedMovieIds)
    }

    func unmarkWatched(_ movieId: Int) {
        var current = watchedMovieIds
        current.remove(movieId)
        defaults.set(Array(current), forKey: Key.watchedMovieIds)
    }

    func hasWatched(_ movieId: Int) -> Bool {
        watchedMovieIds.contains(movieId)
    }

    // MARK: - Last selected mood

    var lastSelectedMoodId: Int? {
        get {
            defaults.object(forKey: Key.lastSelectedMoodId) as? Int
        }
        set {
            if let newValue {
                defaults.set(newValue, forKey: Key.lastSelectedMoodId)
            } else {
                defaults.removeObject(forKey: Key.lastSelectedMoodId)
            }
        }
    }

    // MARK: - Movie ratings

    /// 1–5 star rating per movie. Backed by `[String: Int]` because
    /// UserDefaults requires string keys for dictionaries.
    func rating(for movieId: Int) -> Int? {
        let raw = defaults.dictionary(forKey: Key.movieRatings) as? [String: Int] ?? [:]
        return raw[String(movieId)]
    }

    func setRating(_ rating: Int, for movieId: Int) {
        var raw = defaults.dictionary(forKey: Key.movieRatings) as? [String: Int] ?? [:]
        if rating <= 0 {
            raw.removeValue(forKey: String(movieId))
        } else {
            raw[String(movieId)] = rating
        }
        defaults.set(raw, forKey: Key.movieRatings)
    }

    func removeRating(for movieId: Int) {
        setRating(0, for: movieId)
    }

    // MARK: - Movie reviews (text + rating)

    /// Retrieve a review for a specific movie
    func review(for movieId: Int) -> MovieReview? {
        guard let data = defaults.data(forKey: "\(Key.movieReviews).\(movieId)") else {
            return nil
        }
        return try? JSONDecoder().decode(MovieReview.self, from: data)
    }

    /// Save or update a review (CREATE/UPDATE)
    func saveReview(_ review: MovieReview) {
        guard let data = try? JSONEncoder().encode(review) else { return }
        defaults.set(data, forKey: "\(Key.movieReviews).\(review.movieId)")
        
        // Also update the rating in the ratings dictionary
        setRating(review.rating, for: review.movieId)
    }

    /// Delete a review (DELETE)
    func deleteReview(for movieId: Int) {
        defaults.removeObject(forKey: "\(Key.movieReviews).\(movieId)")
        removeRating(for: movieId)
    }

    /// Get all reviews
    var allReviews: [MovieReview] {
        let allKeys = defaults.dictionaryRepresentation().keys
        let reviewKeys = allKeys.filter { $0.hasPrefix(Key.movieReviews) }
        
        return reviewKeys.compactMap { key in
            guard let data = defaults.data(forKey: key) else { return nil }
            return try? JSONDecoder().decode(MovieReview.self, from: data)
        }
    }

    // MARK: - Current user (session)

    /// Lightweight session record kept locally so Profile can render
    /// without re-fetching. Password is intentionally NOT stored.
    /// When the real API lands, the login response populates these.

    var currentUserId: Int? {
        get { defaults.object(forKey: Key.currentUserId) as? Int }
        set {
            if let newValue {
                defaults.set(newValue, forKey: Key.currentUserId)
            } else {
                defaults.removeObject(forKey: Key.currentUserId)
            }
        }
    }

    var currentUserName: String? {
        get { defaults.string(forKey: Key.currentUserName) }
        set {
            if let newValue {
                defaults.set(newValue, forKey: Key.currentUserName)
            } else {
                defaults.removeObject(forKey: Key.currentUserName)
            }
        }
    }

    var currentUserEmail: String? {
        get { defaults.string(forKey: Key.currentUserEmail) }
        set {
            if let newValue {
                defaults.set(newValue, forKey: Key.currentUserEmail)
            } else {
                defaults.removeObject(forKey: Key.currentUserEmail)
            }
        }
    }

    // MARK: - User preferences

    var hideWatchedMovies: Bool {
        get { defaults.bool(forKey: Key.hideWatchedMovies) }
        set { defaults.set(newValue, forKey: Key.hideWatchedMovies) }
    }

    /// Transient flag set by RegisterView and consumed by ProfileView.
    /// Lets the welcome label say "Welcome" once after sign-up
    /// instead of always "Welcome back".
    var didJustRegister: Bool {
        get { defaults.bool(forKey: Key.didJustRegister) }
        set { defaults.set(newValue, forKey: Key.didJustRegister) }
    }

    // MARK: - Maintenance

    /// Wipes all locally cached preferences.
    /// Call on logout or before a full re-sync from the backend.
    func clearAll() {
        defaults.removeObject(forKey: Key.favoriteMovieIds)
        defaults.removeObject(forKey: Key.watchedMovieIds)
        defaults.removeObject(forKey: Key.lastSelectedMoodId)
        defaults.removeObject(forKey: Key.movieRatings)
        defaults.removeObject(forKey: Key.currentUserId)
        defaults.removeObject(forKey: Key.currentUserName)
        defaults.removeObject(forKey: Key.currentUserEmail)
        defaults.removeObject(forKey: Key.didJustRegister)
        
        // Clear all reviews
        let allKeys = defaults.dictionaryRepresentation().keys
        let reviewKeys = allKeys.filter { $0.hasPrefix(Key.movieReviews) }
        reviewKeys.forEach { defaults.removeObject(forKey: $0) }
    }
}
