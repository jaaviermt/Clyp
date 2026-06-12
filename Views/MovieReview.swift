//
//  MovieReview.swift
//  Clyp
//
//  Created by xav on 12/06/26.
//

import Foundation

struct MovieReview: Codable {
    let movieId: Int
    let text: String
    let rating: Int
    let createdAt: Date
}
