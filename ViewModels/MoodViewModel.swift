//
//  MoodViewModel.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class MoodViewModel {
    private(set) var moods: [Mood] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    private let apiService: APIService
    private let usesMockData: Bool

    init(apiService: APIService = .shared) {
        self.apiService = apiService
        self.usesMockData = false
    }

    /// Preview/mock initializer. `loadMoods()` becomes a no-op
    /// so the view validates without hitting the network.
    init(mockMoods: [Mood]) {
        self.apiService = .shared
        self.usesMockData = true
        self.moods = mockMoods
    }

    func loadMoods() async {
        if usesMockData { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            moods = try await apiService.fetch(.getAllMoods)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
