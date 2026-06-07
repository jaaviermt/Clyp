//
//  ComponentShowcaseView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct ComponentShowcaseView: View {
    @State private var selectedTab: BottomNav.Tab = .discover
    @State private var selectedMoodIndex: Int = 0

    private let moods: [Mood] = [
        Mood(id_mood: 1, name: "Happy",     description: nil),
        Mood(id_mood: 2, name: "Sad",       description: nil),
        Mood(id_mood: 3, name: "Excited",   description: nil),
        Mood(id_mood: 4, name: "Romantic",  description: nil),
        Mood(id_mood: 5, name: "Tense",     description: nil),
        Mood(id_mood: 6, name: "Nostalgic", description: nil)
    ]

    private let mockMovie = Movie(
        id_movie: 1,
        title: "The Grand Budapest Hotel",
        description: nil,
        year: 2014,
        image_url: nil,
        id_genre: 1,
        id_mood: 1
    )

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    logoSection
                    ctaSection
                    moodChipSection
                    moodCardSection
                    posterSection
                    movieCardSection
                    ratingStarsSection
                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            BottomNav(selection: $selectedTab)
        }
        .background(AppColors.cream.ignoresSafeArea())
    }

    // MARK: - Sections

    private var logoSection: some View {
        section("LogoView") {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                LogoView()
                LogoView(font: AppTypography.displayMD, dotSize: 8)
            }
        }
    }

    private var ctaSection: some View {
        section("PrimaryCTAButton") {
            PrimaryCTAButton(title: "Get Started") {}
        }
    }

    private var moodChipSection: some View {
        section("MoodChip") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(Array(moods.enumerated()), id: \.offset) { _, mood in
                        MoodChip(mood: mood)
                    }
                }
            }
        }
    }

    private var moodCardSection: some View {
        section("MoodCard") {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.md),
                    GridItem(.flexible(), spacing: AppSpacing.md)
                ],
                spacing: AppSpacing.md
            ) {
                ForEach(Array(moods.enumerated()), id: \.offset) { index, mood in
                    Button {
                        withAnimation(AppAnimations.tap) {
                            selectedMoodIndex = index
                        }
                    } label: {
                        MoodCard(mood: mood, isSelected: selectedMoodIndex == index)
                    }
                    .buttonStyle(PressableScaleStyle())
                }
            }
        }
    }

    private var posterSection: some View {
        section("PosterView") {
            PosterView(imageURLString: nil)
                .frame(maxWidth: 200)
        }
    }

    private var movieCardSection: some View {
        section("MovieCard") {
            MovieCard(movie: mockMovie, mood: moods[0], rating: 4)
                .frame(maxWidth: 220)
        }
    }

    private var ratingStarsSection: some View {
        section("RatingStars") {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(0...5, id: \.self) { rating in
                    HStack(spacing: AppSpacing.md) {
                        Text("\(rating)")
                            .font(AppTypography.label)
                            .foregroundStyle(AppColors.ink)
                            .frame(width: 16, alignment: .leading)
                        RatingStars(rating: rating)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTypography.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            content()
        }
    }
}

#Preview {
    ComponentShowcaseView()
}
