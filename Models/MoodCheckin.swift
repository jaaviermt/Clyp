//
//  MoodCheckin.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

nonisolated struct MoodCheckin: Codable {
    let id_checkin: Int?
    let id_user: Int
    let id_mood: Int
    let checkin_time: String?
}
