//
//  SplashView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct SplashView: View {
    @State private var showLogin = false

    var body: some View {
        ZStack {
            if showLogin {
                NavigationStack {
                    LoginView()
                }
                .transition(.opacity)
            } else {
                splash
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeInOut(duration: 0.4)) {
                showLogin = true
            }
        }
    }

    private var splash: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            LogoView()
            Text("Movies that match your soul.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.ink.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream.ignoresSafeArea())
    }
}

#Preview {
    SplashView()
}
