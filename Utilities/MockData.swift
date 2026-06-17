//
//  MockData.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

enum MockData {
    /// Single switch to alternate between mock data and the real API.
    /// Persisted in UserDefaults so the Debug sheet can flip it at runtime.
    /// Defaults to `false`: the production backend is live, so the app
    /// hits the API and only falls back to mock data on failure.
    private static let useMockDataKey = "clyp.debug.useMockData"

    static var useMockData: Bool {
        get { UserDefaults.standard.object(forKey: useMockDataKey) as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: useMockDataKey) }
    }

    static let mockUser = User(
        id_user: 1,
        name: "Javier Marín",
        email: "javier@clyp.app",
        password: "mockpass",
        created_at: "2026-06-01T12:34:56Z"
    )

    static let moods: [Mood] = [
        Mood(id_mood: 1, name: "Happy",     description: "Feel-good vibes."),
        Mood(id_mood: 2, name: "Sad",       description: "Slow-burn drama."),
        Mood(id_mood: 3, name: "Excited",   description: "High-energy adventures."),
        Mood(id_mood: 4, name: "Romantic",  description: "Love and longing."),
        Mood(id_mood: 5, name: "Tense",     description: "Edge-of-seat thrillers."),
        Mood(id_mood: 6, name: "Nostalgic", description: "Memory lane.")
    ]

    static let genres: [Genre] = [
        Genre(id_genre: 1, name: "Comedy"),
        Genre(id_genre: 2, name: "Drama"),
        Genre(id_genre: 3, name: "Action"),
        Genre(id_genre: 4, name: "Romance"),
        Genre(id_genre: 5, name: "Thriller"),
        Genre(id_genre: 6, name: "Adventure")
    ]

    static let movies: [Movie] = [
        Movie(
            id_movie: 1,
            title: "The Grand Budapest Hotel",
            description: "A concierge and his protégé in a fictional alpine resort.",
            year: 2014,
            image_url: nil,
            id_genre: 1,
            id_mood: 1
        ),
        Movie(
            id_movie: 2,
            title: "Manchester by the Sea",
            description: "A janitor returns home after a family tragedy.",
            year: 2016,
            image_url: nil,
            id_genre: 2,
            id_mood: 2
        ),
        Movie(
            id_movie: 3,
            title: "Mad Max: Fury Road",
            description: "A high-octane chase across the wasteland.",
            year: 2015,
            image_url: nil,
            id_genre: 3,
            id_mood: 3
        ),
        Movie(
            id_movie: 4,
            title: "Before Sunrise",
            description: "Two strangers spend a night together in Vienna.",
            year: 1995,
            image_url: nil,
            id_genre: 4,
            id_mood: 4
        ),
        Movie(
            id_movie: 5,
            title: "Hereditary",
            description: "A grieving family unravels a sinister legacy.",
            year: 2018,
            image_url: nil,
            id_genre: 5,
            id_mood: 5
        ),
        Movie(
            id_movie: 6,
            title: "Stand by Me",
            description: "Four friends set off on a journey into adolescence.",
            year: 1986,
            image_url: nil,
            id_genre: 6,
            id_mood: 6
        )
    ]
}
