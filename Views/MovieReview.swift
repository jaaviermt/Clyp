//
//  MovieReview.swift
//  Clyp
//
//  Created by xav on 12/06/26.
//

import Foundation

nonisolated struct MovieReview: Codable, Identifiable {
    let movieId: Int
    let text: String
    let rating: Int
    let createdAt: Date
    /// Server-side identifier (`review.id_review`). `nil` until the review
    /// has been created on the backend; needed to call update/delete.
    let id_review: Int?

    var id: Int { movieId }

    init(movieId: Int, text: String, rating: Int, createdAt: Date, id_review: Int? = nil) {
        self.movieId = movieId
        self.text = text
        self.rating = rating
        self.createdAt = createdAt
        self.id_review = id_review
    }
}
