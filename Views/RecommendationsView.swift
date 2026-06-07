//
//  RecommendationsView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct RecommendationsView: View {
    let selectedMood: Mood

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Recommendations")
                .font(AppTypography.displayLG)
                .foregroundStyle(AppColors.ink)
            Text("Selected mood: \(selectedMood.name)")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            Spacer()
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColors.cream.ignoresSafeArea())
    }
}
