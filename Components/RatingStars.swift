//
//  RatingStars.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct RatingStars: View {
    let rating: Int
    var size: CGFloat = 14

    private let maxRating = 5

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(index < rating ? AppColors.clypOrange : AppColors.silverScreen)
            }
        }
    }
}
