//
//  PrimaryCTAButton.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct PrimaryCTAButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Text(title)
                    .font(AppTypography.label)
                    .foregroundStyle(AppColors.cream)
                    .padding(.leading, AppSpacing.xl)

                Spacer(minLength: 0)

                ZStack {
                    Circle()
                        .fill(AppColors.cream)
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.clypOrange)
                }
                .padding(.trailing, AppSpacing.md)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppColors.ink)
            .clipShape(Capsule())
        }
        .buttonStyle(PressableScaleStyle())
    }
}
