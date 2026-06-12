//
//  SecondaryCTAButton.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

/// Secondary call-to-action. Same capsule + height as PrimaryCTAButton,
/// but inverted hierarchy: silverScreen fill, ink (or override) text,
/// no trailing arrow. Use for non-primary actions (logout, undo, cancel-y
/// destructive flows). Keep PrimaryCTAButton for the dominant action.
struct SecondaryCTAButton: View {
    let title: String
    let action: () -> Void
    var foregroundColor: Color = AppColors.ink

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.label)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppColors.silverScreen)
                .clipShape(Capsule())
        }
        .buttonStyle(PressableScaleStyle())
    }
}
