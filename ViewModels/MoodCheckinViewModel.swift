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

    // Edits go through the API (`PUT /checkin/update`, `DELETE /checkin/delete`)
    // and mirror into the local cache; the UI refreshes once they complete.

    func updateCheckin(_ checkin: MoodCheckin, newMoodId: Int, newDate: Date) {
        Task {
            await RemoteSync.updateCheckin(checkin, newMoodId: newMoodId, newDate: newDate)
            load()
        }
    }

    func deleteCheckin(id: Int) {
        Task {
            await RemoteSync.deleteCheckin(id: id)
            load()
        }
    }

    func deleteCheckins(at offsets: IndexSet) {
        let ids = offsets.compactMap { checkins[$0].id_checkin }
        Task {
            for id in ids {
                await RemoteSync.deleteCheckin(id: id)
            }
            load()
        }
    }
}
