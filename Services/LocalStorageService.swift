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

    // MARK: - Maintenance

    /// Wipes all locally cached preferences.
    /// Call on logout or before a full re-sync from the backend.
    func clearAll() {
        defaults.removeObject(forKey: Key.favoriteMovieIds)
        defaults.removeObject(forKey: Key.watchedMovieIds)
        defaults.removeObject(forKey: Key.lastSelectedMoodId)
    }
}
