//
//  Movie.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

struct Movie: Codable {
    let id_movie: Int?
    let title: String
    let description: String?
    let year: Int?
    let image_url: String?
    let id_genre: Int
    let id_mood: Int
}
