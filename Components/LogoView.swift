//
//  LogoView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct LogoView: View {
    var font: Font = AppTypography.displayXL
    var dotSize: CGFloat = 12

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Text("CLYP")
                .font(font)
                .foregroundStyle(AppColors.ink)
            Circle()
                .fill(AppColors.clypOrange)
                .frame(width: dotSize, height: dotSize)
        }
    }
}
