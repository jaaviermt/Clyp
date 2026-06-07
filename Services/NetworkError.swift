//
//  NetworkError.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case missingBaseURL
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case transport(Error)
    case encoding(Error)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .missingBaseURL:
            return "API base URL is not configured."
        case .invalidURL:
            return "Could not build a valid request URL."
        case .invalidResponse:
            return "Server returned an unexpected response."
        case .statusCode(let code):
            return "Server returned status code \(code)."
        case .transport(let error):
            return "Network error: \(error.localizedDescription)"
        case .encoding(let error):
            return "Failed to encode request body: \(error.localizedDescription)"
        case .decoding(let error):
            return "Failed to decode server response: \(error.localizedDescription)"
        }
    }
}
