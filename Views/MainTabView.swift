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
    @State private var profileRefreshToken: UUID = UUID()
    @State private var myListRefreshToken: UUID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                tab(.discover) {
                    NavigationStack { DiscoverView() }
                }
                tab(.myList) {
                    NavigationStack { 
                        MyListView(refreshToken: myListRefreshToken) 
                    }
                }
                tab(.profile) {
                    NavigationStack {
                        ProfileView(
                            refreshToken: profileRefreshToken,
                            onLogout: onLogout
                        )
                    }
                }
            }

            BottomNav(selection: $selectedTab)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .onChange(of: selectedTab) { _, new in
            if new == .profile {
                profileRefreshToken = UUID()
            } else if new == .myList {
                myListRefreshToken = UUID()
            }
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
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
