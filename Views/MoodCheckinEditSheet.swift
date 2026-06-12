//
//  MoodCheckinEditSheet.swift
//  Clyp
//

import SwiftUI

struct MoodCheckinEditSheet: View {
    enum Mode {
        case create
        case edit(MoodCheckin)
    }

    let mode: Mode
    var onSave: (Int, Date) -> Void
    var onDismiss: () -> Void

    @State private var selectedMoodId: Int
    @State private var selectedDate: Date

    private let moods = MockData.moods

    init(mode: Mode, onSave: @escaping (Int, Date) -> Void, onDismiss: @escaping () -> Void) {
        self.mode = mode
        self.onSave = onSave
        self.onDismiss = onDismiss
        switch mode {
        case .create:
            _selectedMoodId = State(initialValue: MockData.moods.first?.id_mood ?? 1)
            _selectedDate   = State(initialValue: Date())
        case .edit(let checkin):
            _selectedMoodId = State(initialValue: checkin.id_mood)
            _selectedDate   = State(initialValue: checkin.date ?? Date())
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            sheetHeader
            moodSelector
            datePicker
            Spacer()
            PrimaryCTAButton(title: "Save Check-in") {
                onSave(selectedMoodId, selectedDate)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cream.ignoresSafeArea())
    }

    // MARK: - Sections

    private var sheetHeader: some View {
        HStack {
            Text(isEditing ? "Edit Check-in" : "New Check-in")
                .font(AppTypography.displaySM)
                .foregroundStyle(AppColors.ink)
            Spacer()
            Button { onDismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.ink)
                    .padding(AppSpacing.sm)
                    .background(AppColors.silverScreen)
                    .clipShape(Circle())
            }
        }
    }

    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Mood")
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.ink.opacity(0.6))

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 3),
                spacing: AppSpacing.sm
            ) {
                ForEach(moods, id: \.id_mood) { mood in
                    let isSelected = mood.id_mood == selectedMoodId
                    Button {
                        selectedMoodId = mood.id_mood ?? selectedMoodId
                    } label: {
                        Text(mood.name)
                            .font(AppTypography.label)
                            .foregroundStyle(isSelected ? mood.foregroundOnColor : AppColors.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                            .background(isSelected ? mood.color : AppColors.silverScreen)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
                    }
                    .buttonStyle(PressableScaleStyle())
                }
            }
        }
    }

    private var datePicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Date & Time")
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.ink.opacity(0.6))

            DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .tint(AppColors.clypOrange)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }
}

#Preview("Create") {
    MoodCheckinEditSheet(mode: .create) { _, _ in } onDismiss: {}
}

#Preview("Edit") {
    MoodCheckinEditSheet(
        mode: .edit(MoodCheckin(id_checkin: 1, id_user: 1, id_mood: 3, checkin_time: ISO8601DateFormatter().string(from: Date())))
    ) { _, _ in } onDismiss: {}
}
