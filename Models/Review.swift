//
//  Review.swift
//  Clyp
//
//  Backend contract for the Review entity. Mirrors `GET /review/getByUser/{id}`
//  items, distinct from the local `MovieReview` used by the UI. `rating` is an
//  integer 1–5; `text` is optional (a rating can exist without a written review).
//

import Foundation

nonisolated struct Review: Codable, Identifiable {
    let id_review: Int?
    let id_user: Int
    let id_movie: Int
    let text: String?
    let rating: Int
    let created_at: String?
    let updated_at: String?

    var id: Int { id_review ?? 0 }
}
