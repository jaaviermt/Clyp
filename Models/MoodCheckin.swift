//
//  MoodCheckin.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

nonisolated struct MoodCheckin: Codable, Identifiable {
    let id_checkin: Int?
    let id_user: Int
    let id_mood: Int
    let checkin_time: String?

    var id: Int { id_checkin ?? 0 }

    var date: Date? {
        guard let s = checkin_time else { return nil }
        return ISO8601DateFormatter().date(from: s)
    }

    var formattedDate: String {
        guard let d = date else { return "—" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: d)
    }
}
