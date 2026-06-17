//
//  CatalogMoodsView.swift
//  Clyp
//
//  Full CRUD for the Mood catalog entity.
//

import SwiftUI

struct CatalogMoodsView: View {
    @State private var viewModel = CatalogViewModel()
    @State private var route: Route?
    @State private var pendingDelete: Mood?

    private enum Route: Identifiable {
        case create
        case edit(Mood)
        var id: String {
            switch self {
            case .create:      return "create"
            case .edit(let m): return "edit-\(m.id_mood ?? 0)"
            }
        }
        var mood: Mood? {
            if case .edit(let m) = self { return m }
            return nil
        }
    }

    private var moods: [Mood] {
        AppData.shared.moods.sorted { ($0.id_mood ?? 0) < ($1.id_mood ?? 0) }
    }

    var body: some View {
        Group {
            if moods.isEmpty {
                CatalogEmptyState(
                    icon: "face.smiling",
                    title: "No moods yet",
                    message: "Tap + to add a mood users can pick in Discover."
                )
            } else {
                list
            }
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Moods")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { route = .create } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.clypOrange)
                }
                .accessibilityLabel("Add mood")
            }
        }
        .sheet(item: $route) { route in
            NavigationStack {
                MoodFormView(existing: route.mood) { draft in
                    Task { await viewModel.saveMood(draft) }
                    self.route = nil
                }
            }
        }
        .alert("Delete mood", isPresented: deleteBinding) {
            Button("Cancel", role: .cancel) { pendingDelete = nil }
            Button("Delete", role: .destructive) {
                if let id = pendingDelete?.id_mood {
                    Task { await viewModel.deleteMood(id: id) }
                }
                pendingDelete = nil
            }
        } message: {
            Text("“\(pendingDelete?.name ?? "")” will be removed. Movies and check-ins using it may be affected.")
        }
    }

    private var list: some View {
        List {
            ForEach(moods, id: \.id_mood) { mood in
                Button { route = .edit(mood) } label: {
                    CatalogRow(title: mood.name, subtitle: mood.description, accent: mood.color)
                }
                .buttonStyle(.plain)
                .listRowBackground(AppColors.cream)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) { pendingDelete = mood } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var deleteBinding: Binding<Bool> {
        Binding(get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } })
    }
}

// MARK: - Create / Edit form

private struct MoodFormView: View {
    let existing: Mood?
    var onSave: (Mood) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var overview: String
    @State private var showNameError = false

    /// Names the app maps to a dedicated color + icon. Anything else falls back
    /// to the default orange with no icon — surfaced as a hint in the form.
    private static let recognized = ["Happy", "Sad", "Excited", "Romantic", "Tense", "Nostalgic"]

    private var isEditing: Bool { existing != nil }
    private var isRecognized: Bool {
        Self.recognized.contains { $0.caseInsensitiveCompare(name.trimmingCharacters(in: .whitespaces)) == .orderedSame }
    }

    init(existing: Mood?, onSave: @escaping (Mood) -> Void) {
        self.existing = existing
        self.onSave = onSave
        _name     = State(initialValue: existing?.name ?? "")
        _overview = State(initialValue: existing?.description ?? "")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                CatalogFieldLabel(title: "Name") {
                    TextField("Mood name", text: $name)
                        .catalogField()
                        .onChange(of: name) { _, _ in showNameError = false }
                    if showNameError {
                        Text("Name is required.")
                            .font(AppTypography.bodySM)
                            .foregroundStyle(AppColors.heartbeat)
                    } else if !name.trimmingCharacters(in: .whitespaces).isEmpty && !isRecognized {
                        Text("Tip: use one of Happy, Sad, Excited, Romantic, Tense or Nostalgic to get a matching color and icon.")
                            .font(AppTypography.bodySM)
                            .foregroundStyle(AppColors.ink.opacity(0.5))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                CatalogFieldLabel(title: "Description") {
                    TextField("What this mood is about", text: $overview, axis: .vertical)
                        .lineLimit(2...4)
                        .catalogField()
                }

                PrimaryCTAButton(title: isEditing ? "Save Changes" : "Add Mood") { save() }
                    .padding(.top, AppSpacing.sm)
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle(isEditing ? "Edit Mood" : "New Mood")
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
        let mood = Mood(
            id_mood: existing?.id_mood,
            name: trimmed,
            description: overview.trimmingCharacters(in: .whitespaces).isEmpty ? nil : overview
        )
        onSave(mood)
        dismiss()
    }
}

#Preview {
    NavigationStack { CatalogMoodsView() }
}
