//
//  MoodCard.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct MoodCard: View {
    let mood: Mood
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            icon
                .frame(width: 56, height: 56)

            Spacer(minLength: AppSpacing.md)

            Text(mood.name)
                .font(AppTypography.displaySM)
                .foregroundStyle(mood.foregroundOnColor)
                .lineLimit(1)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .aspectRatio(1, contentMode: .fit)
        .background(mood.color)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppColors.ink, lineWidth: isSelected ? 4 : 0)
        )
    }

    @ViewBuilder
    private var icon: some View {
        if let assetName = mood.iconAssetName {
            Image(assetName)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "face.smiling")
                .resizable()
                .scaledToFit()
                .foregroundStyle(mood.foregroundOnColor)
        }
    }
}
