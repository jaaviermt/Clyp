//
//  CatalogGenresView.swift
//  Clyp
//
//  Full CRUD for the Genre catalog entity.
//

import SwiftUI

struct CatalogGenresView: View {
    @State private var viewModel = CatalogViewModel()
    @State private var route: Route?
    @State private var pendingDelete: Genre?

    private enum Route: Identifiable {
        case create
        case edit(Genre)
        var id: String {
            switch self {
            case .create:      return "create"
            case .edit(let g): return "edit-\(g.id_genre ?? 0)"
            }
        }
        var genre: Genre? {
            if case .edit(let g) = self { return g }
            return nil
        }
    }

    private var genres: [Genre] {
        AppData.shared.genres.sorted { ($0.id_genre ?? 0) < ($1.id_genre ?? 0) }
    }

    var body: some View {
        Group {
            if genres.isEmpty {
                CatalogEmptyState(
                    icon: "theatermasks",
                    title: "No genres yet",
                    message: "Tap + to add a genre you can assign to movies."
                )
            } else {
                list
            }
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Genres")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { route = .create } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.clypOrange)
                }
                .accessibilityLabel("Add genre")
            }
        }
        .sheet(item: $route) { route in
            NavigationStack {
                GenreFormView(existing: route.genre) { draft in
                    Task { await viewModel.saveGenre(draft) }
                    self.route = nil
                }
            }
        }
        .alert("Delete genre", isPresented: deleteBinding) {
            Button("Cancel", role: .cancel) { pendingDelete = nil }
            Button("Delete", role: .destructive) {
                if let id = pendingDelete?.id_genre {
                    Task { await viewModel.deleteGenre(id: id) }
                }
                pendingDelete = nil
            }
        } message: {
            Text("“\(pendingDelete?.name ?? "")” will be removed. Movies using it may be affected.")
        }
    }

    private var list: some View {
        List {
            ForEach(genres, id: \.id_genre) { genre in
                Button { route = .edit(genre) } label: {
                    CatalogRow(title: genre.name, subtitle: movieCount(for: genre))
                }
                .buttonStyle(.plain)
                .listRowBackground(AppColors.cream)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) { pendingDelete = genre } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func movieCount(for genre: Genre) -> String {
        guard let id = genre.id_genre else { return "" }
        let n = AppData.shared.movies.filter { $0.id_genre == id }.count
        return "\(n) movie\(n == 1 ? "" : "s")"
    }

    private var deleteBinding: Binding<Bool> {
        Binding(get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } })
    }
}

// MARK: - Create / Edit form

private struct GenreFormView: View {
    let existing: Genre?
    var onSave: (Genre) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var showNameError = false

    private var isEditing: Bool { existing != nil }

    init(existing: Genre?, onSave: @escaping (Genre) -> Void) {
        self.existing = existing
        self.onSave = onSave
        _name = State(initialValue: existing?.name ?? "")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                CatalogFieldLabel(title: "Name") {
                    TextField("Genre name", text: $name)
                        .catalogField()
                        .onChange(of: name) { _, _ in showNameError = false }
                    if showNameError {
                        Text("Name is required.")
                            .font(AppTypography.bodySM)
                            .foregroundStyle(AppColors.heartbeat)
                    }
                }

                PrimaryCTAButton(title: isEditing ? "Save Changes" : "Add Genre") { save() }
                    .padding(.top, AppSpacing.sm)
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle(isEditing ? "Edit Genre" : "New Genre")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(AppColors.ink)
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            withAnimation(AppAnimations.tap) { showNameError = true }
            return
        }
        onSave(Genre(id_genre: existing?.id_genre, name: trimmed))
        dismiss()
    }
}

#Preview {
    NavigationStack { CatalogGenresView() }
}
