//
//  Review.swift
//  Clyp
//
//  Backend contract for the Review entity (AJUSTES_BACKEND.md §7.5).
//  Mirrors `GET /review/getByUser/{id}` items. Distinct from the local
//  `MovieReview` used by the UI; the sync layer maps between the two once
//  the endpoints are live. `rating` is an integer 1–5.
//

import Foundation

nonisolated struct Review: Codable, Identifiable {
    let id_review: Int?
    let id_user: Int
    let id_movie: Int
    let text: String
    let rating: Int
    let created_at: String?
    let updated_at: String?

    var id: Int { id_review ?? 0 }
}
