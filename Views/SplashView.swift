//
//  SplashView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct SplashView: View {
    @State private var stage: Stage = .splash

    private enum Stage {
        case splash, auth, main
    }

    var body: some View {
        ZStack {
            switch stage {
            case .splash:
                splash.transition(.opacity)
            case .auth:
                NavigationStack {
                    LoginView(onAuthenticated: advanceToMain)
                }
                .transition(.opacity)
            case .main:
                NavigationStack {
                    DiscoverView()
                }
                .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeInOut(duration: 0.4)) {
                stage = .auth
            }
        }
    }

    private func advanceToMain() {
        withAnimation(.easeInOut(duration: 0.4)) {
            stage = .main
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
