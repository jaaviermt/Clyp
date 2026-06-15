//
//  RemoteSync.swift
//  Clyp
//
//  Bridges the API with the local write-through cache.
//
//  The deployed backend exposes create + list-all for check-ins and
//  watched movies (no per-user / update / delete endpoints yet), so this
//  layer pulls the full lists, filters them by the logged-in user, and
//  mirrors them into LocalStorageService. Writes go to the API first and
//  then update the local cache so the rest of the app stays in sync.
//
import Foundation

@MainActor
enum RemoteSync {
    private static var api: APIService { .shared }
    private static var storage: LocalStorageService { .shared }

    // MARK: - Pull

    /// Pulls the current user's check-ins and watched movies from the API
    /// into the local cache. No-op when there is no active session.
    static func pullCurrentUser() async {
        guard let userId = storage.currentUserId else { return }

        if let checkins: [MoodCheckin] = try? await api.fetch(.getAllCheckins) {
            storage.replaceCheckins(
                checkins
                    .filter { $0.id_user == userId }
                    .sorted { ($0.id_checkin ?? 0) < ($1.id_checkin ?? 0) }
            )
        }

        if let watched: [WatchedMovie] = try? await api.fetch(.getAllWatched) {
            storage.replaceWatched(
                watched
                    .filter { $0.id_user == userId }
                    .map(\.id_movie)
            )
        }
    }

    // MARK: - Push

    /// Creates a check-in on the server and mirrors it locally.
    /// Falls back to a local-only record if the request fails.
    @discardableResult
    static func createCheckin(moodId: Int, date: Date = Date()) async -> MoodCheckin? {
        let userId = storage.currentUserId ?? 1
        let timestamp = ISO8601DateFormatter().string(from: date)

        if let created: MoodCheckin = try? await api.fetch(
            .saveCheckin(id_user: userId, id_mood: moodId, checkin_time: timestamp)
        ) {
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

    /// Marks a movie as watched on the server and mirrors it locally.
    static func markWatched(movieId: Int) async {
        let userId = storage.currentUserId ?? 1
        _ = try? await api.send(.saveWatched(id_user: userId, id_movie: movieId))
        storage.markWatched(movieId)
    }
}
