//
//  CatalogViewModel.swift
//  Clyp
//
//  Drives full CRUD over the catalog entities (Movie, Mood, Genre).
//
//  Pattern mirrors RemoteSync: call the API first and apply the server's
//  result to the shared in-memory catalog (AppData). When the API is
//  unavailable (or the update/delete routes aren't live yet — see
//  Docs/BACKEND_CATALOGO_CRUD.md), it falls back to an optimistic local
//  change so the UI stays responsive. The moment the backend ships the
//  routes, the same code starts persisting server-side with no changes.
//

import Foundation
import Observation

@Observable
@MainActor
final class CatalogViewModel {
    private(set) var isWorking = false
    var errorMessage: String?

    private let api: APIService
    private let data: AppData

    init(api: APIService = .shared) {
        self.api = api
        self.data = .shared
    }

    // Views read the lists straight from `AppData.shared` (observable), so the
    // VM only owns the write commands and transient working/error state.

    // MARK: - Movies

    /// Creates (nil id) or updates a movie. Returns whether the server confirmed.
    @discardableResult
    func saveMovie(_ draft: Movie) async -> Bool {
        await perform {
            let isUpdate = draft.id_movie != nil
            let endpoint: Endpoint = isUpdate ? .updateMovie(draft) : .saveMovie(draft)
            if let saved: Movie = try? await self.api.fetch(endpoint) {
                self.data.upsertMovie(saved)
                return true
            }
            self.data.upsertMovie(isUpdate ? draft : self.withLocalId(draft))
            return false
        }
    }

    func deleteMovie(id: Int) async {
        _ = await perform {
            _ = try? await self.api.send(.deleteMovie(id_movie: id))
            self.data.removeMovie(id: id)
            return true
        }
    }

    // MARK: - Moods

    @discardableResult
    func saveMood(_ draft: Mood) async -> Bool {
        await perform {
            let isUpdate = draft.id_mood != nil
            let endpoint: Endpoint = isUpdate ? .updateMood(draft) : .saveMood(draft)
            if let saved: Mood = try? await self.api.fetch(endpoint) {
                self.data.upsertMood(saved)
                return true
            }
            self.data.upsertMood(isUpdate ? draft : self.withLocalId(draft))
            return false
        }
    }

    func deleteMood(id: Int) async {
        _ = await perform {
            _ = try? await self.api.send(.deleteMood(id_mood: id))
            self.data.removeMood(id: id)
            return true
        }
    }

    // MARK: - Genres

    @discardableResult
    func saveGenre(_ draft: Genre) async -> Bool {
        await perform {
            let isUpdate = draft.id_genre != nil
            let endpoint: Endpoint = isUpdate ? .updateGenre(draft) : .saveGenre(draft)
            if let saved: Genre = try? await self.api.fetch(endpoint) {
                self.data.upsertGenre(saved)
                return true
            }
            self.data.upsertGenre(isUpdate ? draft : self.withLocalId(draft))
            return false
        }
    }

    func deleteGenre(id: Int) async {
        _ = await perform {
            _ = try? await self.api.send(.deleteGenre(id_genre: id))
            self.data.removeGenre(id: id)
            return true
        }
    }

    // MARK: - Helpers

    /// Stamps a synthetic id onto a fresh draft for the optimistic local insert.
    private func withLocalId(_ movie: Movie) -> Movie {
        Movie(id_movie: data.nextLocalMovieId(), title: movie.title,
              description: movie.description, year: movie.year,
              image_url: movie.image_url, id_genre: movie.id_genre, id_mood: movie.id_mood)
    }

    private func withLocalId(_ mood: Mood) -> Mood {
        Mood(id_mood: data.nextLocalMoodId(), name: mood.name, description: mood.description)
    }

    private func withLocalId(_ genre: Genre) -> Genre {
        Genre(id_genre: data.nextLocalGenreId(), name: genre.name)
    }

    private func perform(_ operation: @escaping () async -> Bool) async -> Bool {
        isWorking = true
        defer { isWorking = false }
        return await operation()
    }
}
