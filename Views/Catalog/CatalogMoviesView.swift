//
//  CatalogMoviesView.swift
//  Clyp
//
//  Full CRUD for the Movie catalog entity.
//

import SwiftUI

struct CatalogMoviesView: View {
    @State private var viewModel = CatalogViewModel()
    @State private var route: Route?
    @State private var pendingDelete: Movie?

    private enum Route: Identifiable {
        case create
        case edit(Movie)
        var id: String {
            switch self {
            case .create:         return "create"
            case .edit(let m):    return "edit-\(m.id_movie ?? 0)"
            }
        }
        var movie: Movie? {
            if case .edit(let m) = self { return m }
            return nil
        }
    }

    private var movies: [Movie] {
        AppData.shared.movies.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    var body: some View {
        Group {
            if movies.isEmpty {
                CatalogEmptyState(
                    icon: "film",
                    title: "No movies yet",
                    message: "Tap + to add the first movie to the catalog."
                )
            } else {
                list
            }
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Movies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { route = .create } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.clypOrange)
                }
                .accessibilityLabel("Add movie")
            }
        }
        .sheet(item: $route) { route in
            NavigationStack {
                MovieFormView(existing: route.movie) { draft in
                    Task { await viewModel.saveMovie(draft) }
                    self.route = nil
                }
            }
        }
        .alert("Delete movie", isPresented: deleteBinding) {
            Button("Cancel", role: .cancel) { pendingDelete = nil }
            Button("Delete", role: .destructive) {
                if let id = pendingDelete?.id_movie {
                    Task { await viewModel.deleteMovie(id: id) }
                }
                pendingDelete = nil
            }
        } message: {
            Text("“\(pendingDelete?.title ?? "")” will be removed from the catalog.")
        }
    }

    // MARK: - List

    private var list: some View {
        List {
            ForEach(movies, id: \.id_movie) { movie in
                Button { route = .edit(movie) } label: {
                    CatalogRow(title: movie.title, subtitle: subtitle(for: movie))
                }
                .buttonStyle(.plain)
                .listRowBackground(AppColors.cream)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) { pendingDelete = movie } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func subtitle(for movie: Movie) -> String {
        let genre = AppData.shared.genre(id: movie.id_genre)?.name
        let mood  = AppData.shared.mood(id: movie.id_mood)?.name
        return [genre, mood, movie.year.map(String.init)]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    private var deleteBinding: Binding<Bool> {
        Binding(get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } })
    }
}

// MARK: - Create / Edit form

private struct MovieFormView: View {
    let existing: Movie?
    var onSave: (Movie) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var overview: String
    @State private var yearText: String
    @State private var imageURL: String
    @State private var genreId: Int
    @State private var moodId: Int
    @State private var showTitleError = false

    private var genres: [Genre] { AppData.shared.genres }
    private var moods: [Mood] { AppData.shared.moods }
    private var isEditing: Bool { existing != nil }

    init(existing: Movie?, onSave: @escaping (Movie) -> Void) {
        self.existing = existing
        self.onSave = onSave
        _title    = State(initialValue: existing?.title ?? "")
        _overview = State(initialValue: existing?.description ?? "")
        _yearText = State(initialValue: existing?.year.map(String.init) ?? "")
        _imageURL = State(initialValue: existing?.image_url ?? "")
        _genreId  = State(initialValue: existing?.id_genre ?? AppData.shared.genres.first?.id_genre ?? 1)
        _moodId   = State(initialValue: existing?.id_mood ?? AppData.shared.moods.first?.id_mood ?? 1)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                CatalogFieldLabel(title: "Title") {
                    TextField("Movie title", text: $title)
                        .catalogField()
                        .onChange(of: title) { _, _ in showTitleError = false }
                    if showTitleError {
                        Text("Title is required.")
                            .font(AppTypography.bodySM)
                            .foregroundStyle(AppColors.heartbeat)
                    }
                }

                CatalogFieldLabel(title: "Description") {
                    TextField("Short synopsis", text: $overview, axis: .vertical)
                        .lineLimit(3...6)
                        .catalogField()
                }

                CatalogFieldLabel(title: "Year") {
                    TextField("e.g. 2014", text: $yearText)
                        .keyboardType(.numberPad)
                        .catalogField()
                }

                CatalogFieldLabel(title: "Poster URL") {
                    TextField("https://…", text: $imageURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .catalogField()
                }

                CatalogFieldLabel(title: "Genre") {
                    Picker("Genre", selection: $genreId) {
                        ForEach(genres, id: \.id_genre) { genre in
                            Text(genre.name).tag(genre.id_genre ?? -1)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.clypOrange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .catalogField()
                }

                CatalogFieldLabel(title: "Mood") {
                    Picker("Mood", selection: $moodId) {
                        ForEach(moods, id: \.id_mood) { mood in
                            Text(mood.name).tag(mood.id_mood ?? -1)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.clypOrange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .catalogField()
                }

                PrimaryCTAButton(title: isEditing ? "Save Changes" : "Add Movie") { save() }
                    .padding(.top, AppSpacing.sm)
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle(isEditing ? "Edit Movie" : "New Movie")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(AppColors.ink)
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            withAnimation(AppAnimations.tap) { showTitleError = true }
            return
        }
        let cleanedURL = imageURL.trimmingCharacters(in: .whitespaces)
        let movie = Movie(
            id_movie: existing?.id_movie,
            title: trimmed,
            description: overview.trimmingCharacters(in: .whitespaces).isEmpty ? nil : overview,
            year: Int(yearText.trimmingCharacters(in: .whitespaces)),
            image_url: cleanedURL.isEmpty ? nil : cleanedURL,
            id_genre: genreId,
            id_mood: moodId
        )
        onSave(movie)
        dismiss()
    }
}

#Preview {
    NavigationStack { CatalogMoviesView() }
}
