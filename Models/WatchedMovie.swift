//
//  WatchedMovie.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

nonisolated struct WatchedMovie: Codable {
    let id: Int?
    let id_user: Int
    let id_movie: Int
    let watched_at: String?
}
