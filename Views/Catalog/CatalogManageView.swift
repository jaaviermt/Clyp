//
//  CatalogManageView.swift
//  Clyp
//
//  Hub for managing the shared catalog. Each card opens a full CRUD screen
//  for one entity: Movies, Moods and Genres.
//

import SwiftUI

struct CatalogManageView: View {
    private var data: AppData { .shared }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                links
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Manage Catalog")
        .navigationBarTitleDisplayMode(.inline)
        .task { await data.load() }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Catalog")
                .font(AppTypography.displayLG)
                .foregroundStyle(AppColors.ink)
            Text("Create, edit and remove the movies, moods and genres the app recommends.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, AppSpacing.md)
    }

    private var links: some View {
        VStack(spacing: AppSpacing.md) {
            NavigationLink {
                CatalogMoviesView()
            } label: {
                card(title: "Movies", count: data.movies.count, icon: "film")
            }
            .buttonStyle(.plain)

            NavigationLink {
                CatalogMoodsView()
            } label: {
                card(title: "Moods", count: data.moods.count, icon: "face.smiling")
            }
            .buttonStyle(.plain)

            NavigationLink {
                CatalogGenresView()
            } label: {
                card(title: "Genres", count: data.genres.count, icon: "theatermasks")
            }
            .buttonStyle(.plain)
        }
    }

    private func card(title: String, count: Int, icon: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColors.clypOrange)
                .frame(width: 44, height: 44)
                .background(AppColors.cream)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.displaySM)
                    .foregroundStyle(AppColors.ink)
                Text("\(count) item\(count == 1 ? "" : "s")")
                    .font(AppTypography.bodySM)
                    .foregroundStyle(AppColors.ink.opacity(0.6))
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.clypOrange)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.silverScreen)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }
}

#Preview {
    NavigationStack { CatalogManageView() }
}
