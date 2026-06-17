//
//  CatalogShared.swift
//  Clyp
//
//  Shared building blocks for the catalog management screens
//  (Movies / Moods / Genres). Keeps the three CRUD screens DRY and
//  consistent with the app's design system.
//

import SwiftUI

/// A single tappable row in a management list: title, optional subtitle, an
/// optional color dot (used for moods) and the standard orange chevron.
struct CatalogRow: View {
    let title: String
    var subtitle: String? = nil
    var accent: Color? = nil

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if let accent {
                Circle()
                    .fill(accent)
                    .frame(width: 14, height: 14)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.ink)
                    .lineLimit(1)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTypography.bodySM)
                        .foregroundStyle(AppColors.ink.opacity(0.6))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.clypOrange)
        }
        .padding(.vertical, AppSpacing.xs)
        .contentShape(Rectangle())
    }
}

/// Empty-state used by every management list when it has no rows yet.
struct CatalogEmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(AppColors.ink.opacity(0.25))
            Text(title)
                .font(AppTypography.displaySM)
                .foregroundStyle(AppColors.ink)
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .padding(AppSpacing.xl)
    }
}

extension View {
    /// Rounded, silver-screen filled input style shared by the catalog forms.
    func catalogField() -> some View {
        self
            .font(AppTypography.body)
            .foregroundStyle(AppColors.ink)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.silverScreen)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

/// Labelled field wrapper: an uppercase eyebrow caption above its content.
struct CatalogFieldLabel<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            content
        }
    }
}
