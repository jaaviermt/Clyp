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

    func createCheckin(moodId: Int, date: Date = Date()) {
        let userId = storage.currentUserId ?? 1
        storage.saveCheckin(MoodCheckin(
            id_checkin: nil,
            id_user: userId,
            id_mood: moodId,
            checkin_time: ISO8601DateFormatter().string(from: date)
        ))
        load()
    }

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
