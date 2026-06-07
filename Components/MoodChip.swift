//
//  MoodChip.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct MoodChip: View {
    let mood: Mood

    var body: some View {
        Text(mood.name)
            .font(AppTypography.chip)
            .textCase(.uppercase)
            .foregroundStyle(mood.foregroundOnColor)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(mood.color)
            .clipShape(Capsule())
    }
}
