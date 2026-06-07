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

    /// When provided, each star becomes a tappable button passing
    /// the selected value (1...5). When nil, the row is read-only.
    var onSelect: ((Int) -> Void)?

    private let maxRating = 5

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<maxRating, id: \.self) { index in
                star(at: index)
            }
        }
    }

    @ViewBuilder
    private func star(at index: Int) -> some View {
        let icon = Image(systemName: index < rating ? "star.fill" : "star")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(index < rating ? AppColors.clypOrange : AppColors.silverScreen)

        if let onSelect {
            Button {
                onSelect(index + 1)
            } label: {
                icon
            }
            .buttonStyle(.plain)
        } else {
            icon
        }
    }
}
