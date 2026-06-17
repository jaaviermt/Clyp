//
//  RemoteSync.swift
//  Clyp
//
//  Bridges the API with the local cache: pulls each entity for the logged-in
//  user into LocalStorageService and, on writes, updates the API and the cache.
//
import Foundation

@MainActor
enum RemoteSync {
    private static var api: APIService { .shared }
    private static var storage: LocalStorageService { .shared }

    private static let iso = ISO8601DateFormatter()

    // MARK: - Pull

    /// Pulls the current user's check-ins, watched movies, favorites and
    /// reviews from the API into the local cache. No-op without a session.
    static func pullCurrentUser() async {
        guard let userId = storage.currentUserId else { return }

        if let checkins: [MoodCheckin] = try? await api.fetch(.getCheckinsByUser(id_user: userId)) {
            storage.replaceCheckins(
                checkins.sorted { ($0.id_checkin ?? 0) < ($1.id_checkin ?? 0) }
            )
        }

        if let watched: [WatchedMovie] = try? await api.fetch(.getWatchedByUser(id_user: userId)) {
            storage.replaceWatched(watched.map(\.id_movie))
        }

        if let favorites: [Favorite] = try? await api.fetch(.getFavoritesByUser(id_user: userId)) {
            storage.replaceFavorites(favorites.map(\.id_movie))
        }

        if let reviews: [Review] = try? await api.fetch(.getReviewsByUser(id_user: userId)) {
            storage.replaceReviews(reviews.map(mapReview))
        }
    }

    // MARK: - Check-ins

    /// Creates a check-in on the server and mirrors it locally.
    ///
    /// The server rejects a `checkin_time` for now, so on failure we retry
    /// without it and the server stamps the current time. Falls back to a
    /// local-only record if both attempts fail.
    @discardableResult
    static func createCheckin(moodId: Int, date: Date = Date()) async -> MoodCheckin? {
        let userId = storage.currentUserId ?? 1
        let timestamp = iso.string(from: date)

        var created: MoodCheckin? = try? await api.fetch(
            .saveCheckin(id_user: userId, id_mood: moodId, checkin_time: timestamp)
        )
        if created == nil {
            created = try? await api.fetch(
                .saveCheckin(id_user: userId, id_mood: moodId, checkin_time: nil)
            )
        }
        if let created {
            storage.saveCheckin(created)
            return created
        }

        // Offline fallback: keep the action locally so the UI still responds.
        let local = MoodCheckin(
            id_checkin: nil,
            id_user: userId,
            id_mood: moodId,
            checkin_time: timestamp
        )
        storage.saveCheckin(local)
        return local
    }

    /// Updates a check-in and mirrors it locally. Same `checkin_time` retry
    /// as `createCheckin`.
    static func updateCheckin(_ checkin: MoodCheckin, newMoodId: Int, newDate: Date) async {
        let timestamp = iso.string(from: newDate)

        if let id = checkin.id_checkin {
            var updated: MoodCheckin? = try? await api.fetch(
                .updateCheckin(id_checkin: id, id_mood: newMoodId, checkin_time: timestamp)
            )
            if updated == nil {
                updated = try? await api.fetch(
                    .updateCheckin(id_checkin: id, id_mood: newMoodId, checkin_time: nil)
                )
            }
            if let updated {
                // The update response may omit checkin_time; keep the chosen one.
                storage.saveCheckin(MoodCheckin(
                    id_checkin: updated.id_checkin,
                    id_user: updated.id_user,
                    id_mood: updated.id_mood,
                    checkin_time: updated.checkin_time ?? timestamp
                ))
                return
            }
        }

        // Fallback: keep the user's edit locally (conserve id_user).
        storage.saveCheckin(MoodCheckin(
            id_checkin: checkin.id_checkin,
            id_user: checkin.id_user,
            id_mood: newMoodId,
            checkin_time: timestamp
        ))
    }

    /// Deletes a check-in via `DELETE /checkin/delete/{id}` and mirrors locally.
    static func deleteCheckin(id: Int) async {
        _ = try? await api.send(.deleteCheckin(id_checkin: id))
        storage.deleteCheckin(id: id)
    }

    // MARK: - Watched

    /// Marks a movie as watched on the server and mirrors it locally.
    static func markWatched(movieId: Int) async {
        let userId = storage.currentUserId ?? 1
        _ = try? await api.send(.saveWatched(id_user: userId, id_movie: movieId))
        storage.markWatched(movieId)
    }

    /// Unmarks a watched movie via `DELETE /watched/deleteByUserAndMovie`.
    static func unmarkWatched(movieId: Int) async {
        let userId = storage.currentUserId ?? 1
        _ = try? await api.send(.deleteWatched(id_user: userId, id_movie: movieId))
        storage.unmarkWatched(movieId)
    }

    // MARK: - Favorites

    /// Adds a favorite. Optimistic: the local cache is updated regardless, and
    /// the API call is best-effort (a duplicate is harmless).
    static func addFavorite(movieId: Int) async {
        let userId = storage.currentUserId ?? 1
        storage.addFavorite(movieId)
        _ = try? await api.send(.saveFavorite(id_user: userId, id_movie: movieId))
    }

    /// Removes a favorite via `DELETE /favorite/deleteByUserAndMovie`.
    static func removeFavorite(movieId: Int) async {
        let userId = storage.currentUserId ?? 1
        storage.removeFavorite(movieId)
        _ = try? await api.send(.deleteFavorite(id_user: userId, id_movie: movieId))
    }

    // MARK: - Reviews

    /// Creates or updates a full review (text + rating) and mirrors it locally.
    /// Uses `PUT /review/update` when the movie already has a server review,
    /// otherwise `POST /review/save`.
    ///
    /// Rating or reviewing a movie implies you watched it, so the movie is
    /// also marked as watched (a movie can still be watched without a rating).
    static func saveReview(movieId: Int, text: String, rating: Int) async {
        let userId = storage.currentUserId ?? 1
        let existingId = storage.review(for: movieId)?.id_review

        await markWatched(movieId: movieId)

        let endpoint: Endpoint = existingId.map {
            .updateReview(id_review: $0, text: text, rating: rating)
        } ?? .saveReview(id_user: userId, id_movie: movieId, text: text, rating: rating)

        if let saved: Review = try? await api.fetch(endpoint) {
            storage.saveReview(mapReview(saved))
            return
        }

        // Fallback: keep the edit locally so the UI reflects it immediately.
        storage.saveReview(MovieReview(
            movieId: movieId,
            text: text,
            rating: rating,
            createdAt: Date(),
            id_review: existingId
        ))
    }

    /// Deletes a review via `DELETE /review/delete/{id}` and mirrors locally.
    static func deleteReview(movieId: Int) async {
        if let id = storage.review(for: movieId)?.id_review {
            _ = try? await api.send(.deleteReview(id_review: id))
        }
        storage.deleteReview(for: movieId)
    }

    // MARK: - User

    /// Updates the account via `PUT /user/update` and refreshes the local
    /// session. Throws so callers can surface a duplicate-email 409.
    static func updateUser(name: String, email: String) async throws {
        guard let userId = storage.currentUserId else { return }
        let updated: User = try await api.fetch(
            .updateUser(id_user: userId, name: name, email: email)
        )
        storage.currentUserName  = updated.name
        storage.currentUserEmail = updated.email
    }

    /// Deletes the account via `DELETE /user/delete/{id}` (cascades server-side)
    /// and wipes the local cache.
    static func deleteAccount() async {
        if let userId = storage.currentUserId {
            _ = try? await api.send(.deleteUser(id_user: userId))
        }
        storage.clearAll()
    }

    // MARK: - Mapping

    /// Maps the API `Review` contract onto the UI's local `MovieReview`.
    private static func mapReview(_ review: Review) -> MovieReview {
        let date = review.created_at.flatMap(iso.date(from:)) ?? Date()
        return MovieReview(
            movieId: review.id_movie,
            text: review.text,
            rating: review.rating,
            createdAt: date,
            id_review: review.id_review
        )
    }
}
