//
//  ProfileView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Profile")
                .font(AppTypography.displayLG)
                .foregroundStyle(AppColors.ink)
            Text("Mood history and personal stats will live here.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            Spacer()
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColors.cream.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
