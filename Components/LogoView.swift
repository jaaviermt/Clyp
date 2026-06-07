//
//  LogoView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct LogoView: View {
    var font: Font = AppTypography.displayXL
    var logoSize: CGFloat = 32
    var textColor: Color = AppColors.ink

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image("LogoMark")
                .resizable()
                .scaledToFit()
                .frame(width: logoSize, height: logoSize)
            
            Text("Clyp")
                .font(font)
                .foregroundStyle(textColor)
        }
    }
}
