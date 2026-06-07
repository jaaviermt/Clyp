//
//  MovieViewModel.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class MovieViewModel {
    private(set) var movies: [Movie] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func loadMovies() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            movies = try await apiService.fetch(.getAllMovies)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
