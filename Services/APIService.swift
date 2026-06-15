//
//  APIService.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation

actor APIService {
    static let shared = APIService()

    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - Base URL

    private static let baseURLKey = "clyp.api.baseURL"

    /// Production backend (Render). The DB lives on Azure behind it.
    /// Endpoints hang off `/api`, e.g. `/api/mood/getAll`.
    static let productionBaseURL = "https://api-clyp.onrender.com/api"

    static func setBaseURL(_ urlString: String) {
        UserDefaults.standard.set(urlString, forKey: baseURLKey)
    }

    /// Returns the user-overridden URL (Debug sheet) when present,
    /// otherwise falls back to the production backend.
    static var baseURL: URL? {
        let stored = UserDefaults.standard.string(forKey: baseURLKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let stored, !stored.isEmpty {
            return URL(string: stored)
        }
        return URL(string: productionBaseURL)
    }

    // MARK: - Public API

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await perform(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    func send(_ endpoint: Endpoint) async throws {
        _ = try await perform(endpoint)
    }

    // MARK: - Request pipeline

    private func perform(_ endpoint: Endpoint) async throws -> Data {
        guard let base = Self.baseURL else {
            throw NetworkError.missingBaseURL
        }
        guard let url = composedURL(base: base, path: endpoint.path) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        do {
            if let body = try endpoint.makeBody(encoder: encoder) {
                request.httpBody = body
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkError.encoding(error)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.statusCode(http.statusCode)
        }

        return data
    }

    private nonisolated func composedURL(base: URL, path: String) -> URL? {
        var baseString = base.absoluteString
        if baseString.hasSuffix("/") { baseString.removeLast() }
        var endpointPath = path
        if !endpointPath.hasPrefix("/") { endpointPath = "/" + endpointPath }
        return URL(string: baseString + endpointPath)
    }
}
