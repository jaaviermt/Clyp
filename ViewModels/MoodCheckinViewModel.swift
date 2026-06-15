//
//  MoodCheckinViewModel.swift
//  Clyp
//

import Foundation
import Observation

@Observable
@MainActor
final class MoodCheckinViewModel {
    private(set) var checkins: [MoodCheckin] = []
    private let storage: LocalStorageService

    init(storage: LocalStorageService = .shared) {
        self.storage = storage
        load()
    }

    func load() {
        checkins = storage.allCheckins.sorted {
            ($0.date ?? .distantPast) > ($1.date ?? .distantPast)
        }
    }

    /// Pulls the latest check-ins from the API into the local cache,
    /// then refreshes the in-memory list.
    func refresh() async {
        await RemoteSync.pullCurrentUser()
        load()
    }

    func createCheckin(moodId: Int, date: Date = Date()) {
        Task {
            await RemoteSync.createCheckin(moodId: moodId, date: date)
            load()
        }
    }

    // NOTE: The deployed API has no update/delete endpoint for check-ins,
    // so these edit the local cache only. They take effect immediately and
    // persist for the session; a fresh launch re-syncs from the server.

    func updateCheckin(_ checkin: MoodCheckin, newMoodId: Int, newDate: Date) {
        storage.saveCheckin(MoodCheckin(
            id_checkin: checkin.id_checkin,
            id_user: checkin.id_user,
            id_mood: newMoodId,
            checkin_time: ISO8601DateFormatter().string(from: newDate)
        ))
        load()
    }

    func deleteCheckin(id: Int) {
        storage.deleteCheckin(id: id)
        load()
    }

    func deleteCheckins(at offsets: IndexSet) {
        offsets.forEach { idx in
            if let id = checkins[idx].id_checkin {
                storage.deleteCheckin(id: id)
            }
        }
        load()
    }
}
