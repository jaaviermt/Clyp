//
//  BottomNav.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct BottomNav: View {
    enum Tab: CaseIterable, Hashable {
        case discover
        case myList
        case profile

        var title: String {
            switch self {
            case .discover: return "Discover"
            case .myList:   return "My List"
            case .profile:  return "Profile"
            }
        }
    }

    @Binding var selection: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(AppAnimations.tabs) {
                        selection = tab
                    }
                } label: {
                    Text(tab.title)
                        .font(AppTypography.nav)
                        .textCase(.uppercase)
                        .foregroundStyle(color(for: tab))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(AppColors.cream)
    }

    private func color(for tab: Tab) -> Color {
        selection == tab ? AppColors.clypOrange : AppColors.ink.opacity(0.6)
    }
}
