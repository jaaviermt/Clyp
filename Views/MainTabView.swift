//
//  MainTabView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct MainTabView: View {
    var onLogout: () -> Void = {}

    @State private var selectedTab: BottomNav.Tab = .discover

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                tab(.discover) {
                    NavigationStack { DiscoverView() }
                }
                tab(.myList) {
                    NavigationStack { MyListView() }
                }
                tab(.profile) {
                    NavigationStack { ProfileView(onLogout: onLogout) }
                }
            }

            BottomNav(selection: $selectedTab)
        }
        .background(AppColors.cream.ignoresSafeArea())
    }

    /// Keeps each tab's NavigationStack alive so its state and
    /// scroll position persist across tab switches.
    @ViewBuilder
    private func tab<Content: View>(
        _ tab: BottomNav.Tab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .opacity(selectedTab == tab ? 1 : 0)
            .allowsHitTesting(selectedTab == tab)
    }
}

#Preview {
    MainTabView()
}
