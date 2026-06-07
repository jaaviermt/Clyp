//
//  MyListView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct MyListView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("My List")
                .font(AppTypography.displayLG)
                .foregroundStyle(AppColors.ink)
            Text("Your saved and watched movies will live here.")
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
    NavigationStack { MyListView() }
}
