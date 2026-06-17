//
//  Endpoint.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

enum Endpoint {
    // MARK: Catalog
    case getAllMoods
    case saveMood(Mood)

    case getAllMovies
    case saveMovie(Movie)

    case getAllGenres

    // MARK: Users
    case getAllUsers
    case saveUser(User)
    case loginUser(email: String, password: String)
    case updateUser(id_user: Int, name: String, email: String)        // §7.6
    case deleteUser(id_user: Int)                                      // §7.6

    // MARK: Check-ins
    case getAllCheckins
    case getCheckinsByUser(id_user: Int)                              // §7.1
    case saveCheckin(id_user: Int, id_mood: Int, checkin_time: String?)
    case updateCheckin(id_checkin: Int, id_mood: Int, checkin_time: String?) // §7.2
    case deleteCheckin(id_checkin: Int)                              // §7.2

    // MARK: Watched
    case getAllWatched
    case getWatchedByUser(id_user: Int)                              // §7.1
    case saveWatched(id_user: Int, id_movie: Int)
    case deleteWatched(id_user: Int, id_movie: Int)                  // §7.3

    // MARK: Favorites (§7.4)
    case getFavoritesByUser(id_user: Int)
    case saveFavorite(id_user: Int, id_movie: Int)
    case deleteFavorite(id_user: Int, id_movie: Int)

    // MARK: Reviews (§7.5)
    case getReviewsByUser(id_user: Int)
    case getReviewByUserAndMovie(id_user: Int, id_movie: Int)
    case saveReview(id_user: Int, id_movie: Int, text: String?, rating: Int)
    case updateReview(id_review: Int, text: String?, rating: Int)
    case deleteReview(id_review: Int)

    nonisolated var path: String {
        switch self {
        case .getAllMoods:    return "/mood/getAll"
        case .saveMood:       return "/mood/save"
        case .getAllMovies:   return "/movie/getAll"
        case .saveMovie:      return "/movie/save"
        case .getAllGenres:   return "/genre/getAll"

        case .getAllUsers:    return "/user/getAll"
        case .saveUser:       return "/user/save"
        case .loginUser:      return "/user/login"
        case .updateUser:     return "/user/update"
        case .deleteUser(let id): return "/user/delete/\(id)"

        case .getAllCheckins: return "/checkin/getAll"
        case .getCheckinsByUser(let id): return "/checkin/getByUser/\(id)"
        case .saveCheckin:    return "/checkin/save"
        case .updateCheckin:  return "/checkin/update"
        case .deleteCheckin(let id): return "/checkin/delete/\(id)"

        case .getAllWatched:  return "/watched/getAll"
        case .getWatchedByUser(let id): return "/watched/getByUser/\(id)"
        case .saveWatched:    return "/watched/save"
        case .deleteWatched(let user, let movie):
            return "/watched/deleteByUserAndMovie?id_user=\(user)&id_movie=\(movie)"

        case .getFavoritesByUser(let id): return "/favorite/getByUser/\(id)"
        case .saveFavorite:   return "/favorite/save"
        case .deleteFavorite(let user, let movie):
            return "/favorite/deleteByUserAndMovie?id_user=\(user)&id_movie=\(movie)"

        case .getReviewsByUser(let id): return "/review/getByUser/\(id)"
        case .getReviewByUserAndMovie(let user, let movie):
            return "/review/getByUserAndMovie?id_user=\(user)&id_movie=\(movie)"
        case .saveReview:     return "/review/save"
        case .updateReview:   return "/review/update"
        case .deleteReview(let id): return "/review/delete/\(id)"
        }
    }

    nonisolated var method: HTTPMethod {
        switch self {
        case .getAllMoods, .getAllMovies, .getAllGenres,
             .getAllUsers, .getAllCheckins, .getCheckinsByUser,
             .getAllWatched, .getWatchedByUser,
             .getFavoritesByUser, .getReviewsByUser, .getReviewByUserAndMovie:
            return .get

        case .saveMood, .saveMovie, .saveUser, .loginUser,
             .saveCheckin, .saveWatched, .saveFavorite, .saveReview:
            return .post

        case .updateUser, .updateCheckin, .updateReview:
            return .put

        case .deleteUser, .deleteCheckin, .deleteWatched,
             .deleteFavorite, .deleteReview:
            return .delete
        }
    }

    nonisolated func makeBody(encoder: JSONEncoder) throws -> Data? {
        switch self {
        // No body: GETs and path/query-only DELETEs.
        case .getAllMoods, .getAllMovies, .getAllGenres,
             .getAllUsers, .getAllCheckins, .getCheckinsByUser,
             .getAllWatched, .getWatchedByUser,
             .getFavoritesByUser, .getReviewsByUser, .getReviewByUserAndMovie,
             .deleteUser, .deleteCheckin, .deleteWatched,
             .deleteFavorite, .deleteReview:
            return nil

        case .saveMood(let mood):
            return try encoder.encode(mood)
        case .saveMovie(let movie):
            return try encoder.encode(movie)
        case .saveUser(let user):
            return try encoder.encode(user)
        case .loginUser(let email, let password):
            return try encoder.encode(["email": email, "password": password])
        case .updateUser(let id, let name, let email):
            return try encoder.encode(UserUpdateBody(id_user: id, name: name, email: email))

        case .saveCheckin(let id_user, let id_mood, let checkin_time):
            return try encoder.encode(CheckinBody(
                id_user: id_user, id_mood: id_mood, checkin_time: checkin_time
            ))
        case .updateCheckin(let id_checkin, let id_mood, let checkin_time):
            return try encoder.encode(CheckinUpdateBody(
                id_checkin: id_checkin, id_mood: id_mood, checkin_time: checkin_time
            ))

        case .saveWatched(let id_user, let id_movie):
            return try encoder.encode(["id_user": id_user, "id_movie": id_movie])

        case .saveFavorite(let id_user, let id_movie):
            return try encoder.encode(["id_user": id_user, "id_movie": id_movie])

        case .saveReview(let id_user, let id_movie, let text, let rating):
            return try encoder.encode(ReviewSaveBody(
                id_user: id_user, id_movie: id_movie, text: text, rating: rating
            ))
        case .updateReview(let id_review, let text, let rating):
            return try encoder.encode(ReviewUpdateBody(
                id_review: id_review, text: text, rating: rating
            ))
        }
    }
}

// MARK: - Request bodies
//
// Dedicated Encodable structs so the JSON field names match the backend
// contract exactly (AJUSTES_BACKEND.md §5 and §7).

/// Body for `POST /checkin/save`. Sent with `checkin_time` so the server
/// stores the exact moment the user picked (it may be back-dated from the
/// editor); the server falls back to "now" if nil.
private nonisolated struct CheckinBody: Encodable {
    let id_user: Int
    let id_mood: Int
    let checkin_time: String?
}

/// Body for `PUT /checkin/update`.
private nonisolated struct CheckinUpdateBody: Encodable {
    let id_checkin: Int
    let id_mood: Int
    let checkin_time: String?
}

/// Body for `PUT /user/update` (never sends `password`).
private nonisolated struct UserUpdateBody: Encodable {
    let id_user: Int
    let name: String
    let email: String
}

/// Body for `POST /review/save`. A nil `text` is omitted from the JSON, so the
/// server stores a rating with no written review.
private nonisolated struct ReviewSaveBody: Encodable {
    let id_user: Int
    let id_movie: Int
    let text: String?
    let rating: Int
}

/// Body for `PUT /review/update`.
private nonisolated struct ReviewUpdateBody: Encodable {
    let id_review: Int
    let text: String?
    let rating: Int
}
