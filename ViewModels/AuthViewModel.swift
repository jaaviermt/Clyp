//
//  AuthViewModel.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class AuthViewModel {
    private(set) var isLoading = false
    var errorMessage: String?

    private let apiService: APIService
    private let storage: LocalStorageService

    init(apiService: APIService = .shared,
         storage: LocalStorageService = .shared) {
        self.apiService = apiService
        self.storage = storage
    }

    /// Authenticates against `POST /user/login`. On success the session is
    /// persisted locally and the user's remote data is pulled. Returns
    /// `true` when login succeeded.
    func login(email: String, password: String) async -> Bool {
        await run {
            let user: User = try await self.apiService.fetch(
                .loginUser(email: email, password: password)
            )
            self.persistSession(user, justRegistered: false)
            await RemoteSync.pullCurrentUser()
            return true
        } mapError: { error in
            if case NetworkError.statusCode(401) = error {
                return "Email o contraseña incorrectos."
            }
            return "No pudimos iniciar sesión. Revisa tu conexión."
        }
    }

    /// Registers via `POST /user/save`, which returns the created user
    /// with its `id_user`. Persists the session and flags a fresh sign-up.
    func register(name: String, email: String, password: String) async -> Bool {
        let newUser = User(
            id_user: nil,
            name: name,
            email: email,
            password: password,
            created_at: nil
        )
        return await run {
            let created: User = try await self.apiService.fetch(.saveUser(newUser))
            self.persistSession(created, justRegistered: true)
            return true
        } mapError: { error in
            if case NetworkError.statusCode(409) = error {
                return "Ese email ya está registrado."
            }
            return "No pudimos crear la cuenta. Revisa tu conexión."
        }
    }

    // MARK: - Helpers

    private func persistSession(_ user: User, justRegistered: Bool) {
        storage.currentUserId    = user.id_user
        storage.currentUserName  = user.name
        storage.currentUserEmail = user.email
        storage.didJustRegister  = justRegistered
    }

    /// Runs an async auth operation with shared loading/error handling.
    private func run(
        _ operation: @escaping () async throws -> Bool,
        mapError: @escaping (Error) -> String
    ) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            return try await operation()
        } catch {
            errorMessage = mapError(error)
            return false
        }
    }
}
