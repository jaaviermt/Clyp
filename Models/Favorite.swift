//
//  Favorite.swift
//  Clyp
//
//  Backend contract for the Favorite entity (AJUSTES_BACKEND.md §7.4).
//  Mirrors `GET /favorite/getByUser/{id}` items. The app currently keeps
//  favorites locally (LocalStorageService); this is the remote shape the
//  sync layer will map to/from once the endpoints are live.
//

import Foundation

nonisolated struct Favorite: Codable, Identifiable {
    let id_favorite: Int?
    let id_user: Int
    let id_movie: Int
    let favorited_at: String?

    var id: Int { id_favorite ?? 0 }
}
