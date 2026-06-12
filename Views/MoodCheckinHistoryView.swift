//
//  MoodCheckinHistoryView.swift
//  Clyp
//

import SwiftUI

struct MoodCheckinHistoryView: View {
    @State private var viewModel = MoodCheckinViewModel()
    @State private var showAddSheet = false
    @State private var checkinToEdit: MoodCheckin?

    var body: some View {
        Group {
            if viewModel.checkins.isEmpty {
                emptyState
            } else {
                checkinList
            }
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Mood History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.clypOrange)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            MoodCheckinEditSheet(mode: .create) { moodId, date in
                viewModel.createCheckin(moodId: moodId, date: date)
                showAddSheet = false
            } onDismiss: {
                showAddSheet = false
            }
            .presentationDetents([.medium])
        }
        .sheet(item: $checkinToEdit) { checkin in
            MoodCheckinEditSheet(mode: .edit(checkin)) { moodId, date in
                viewModel.updateCheckin(checkin, newMoodId: moodId, newDate: date)
                checkinToEdit = nil
            } onDismiss: {
                checkinToEdit = nil
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Sections

    private var checkinList: some View {
        List {
            ForEach(viewModel.checkins) { checkin in
                Button {
                    checkinToEdit = checkin
                } label: {
                    checkinRow(checkin)
                }
                .buttonStyle(.plain)
                .listRowBackground(AppColors.cream)
            }
            .onDelete { offsets in
                viewModel.deleteCheckins(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func checkinRow(_ checkin: MoodCheckin) -> some View {
        let mood = MockData.moods.first { $0.id_mood == checkin.id_mood }
        return HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(mood?.color ?? AppColors.silverScreen)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(mood?.name ?? "Unknown")
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.ink)
                Text(checkin.formattedDate)
                    .font(AppTypography.bodySM)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.clypOrange)
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Text("No check-ins yet")
                .font(AppTypography.displaySM)
                .foregroundStyle(AppColors.ink)
            Text("Select a mood in Discover or tap + to add one.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview {
    NavigationStack { MoodCheckinHistoryView() }
}
