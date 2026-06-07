//
//  Endpoint.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

enum HTTPMethod: String {
    case get  = "GET"
    case post = "POST"
}

enum Endpoint {
    case getAllMoods
    case saveMood(Mood)

    case getAllMovies
    case saveMovie(Movie)

    case getAllUsers
    case saveUser(User)

    case getAllCheckins
    case saveCheckin(id_user: Int, id_mood: Int)

    case getAllWatched
    case saveWatched(id_user: Int, id_movie: Int)

    var path: String {
        switch self {
        case .getAllMoods:    return "/mood/getAll"
        case .saveMood:       return "/mood/save"
        case .getAllMovies:   return "/movie/getAll"
        case .saveMovie:      return "/movie/save"
        case .getAllUsers:    return "/user/getAll"
        case .saveUser:       return "/user/save"
        case .getAllCheckins: return "/checkin/getAll"
        case .saveCheckin:    return "/checkin/save"
        case .getAllWatched:  return "/watched/getAll"
        case .saveWatched:    return "/watched/save"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getAllMoods, .getAllMovies, .getAllUsers, .getAllCheckins, .getAllWatched:
            return .get
        case .saveMood, .saveMovie, .saveUser, .saveCheckin, .saveWatched:
            return .post
        }
    }

    func makeBody(encoder: JSONEncoder) throws -> Data? {
        switch self {
        case .getAllMoods, .getAllMovies, .getAllUsers, .getAllCheckins, .getAllWatched:
            return nil
        case .saveMood(let mood):
            return try encoder.encode(mood)
        case .saveMovie(let movie):
            return try encoder.encode(movie)
        case .saveUser(let user):
            return try encoder.encode(user)
        case .saveCheckin(let id_user, let id_mood):
            return try encoder.encode(["id_user": id_user, "id_mood": id_mood])
        case .saveWatched(let id_user, let id_movie):
            return try encoder.encode(["id_user": id_user, "id_movie": id_movie])
        }
    }
}
