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
                MainTabView(onLogout: handleLogout)
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

    private func handleLogout() {
        withAnimation(.easeInOut(duration: 0.4)) {
            stage = .auth
        }
    }

    private var splash: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            VStack(spacing: AppSpacing.sm) {
                Image("LogoMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.clypOrange.ignoresSafeArea())
    }
}

#Preview {
    SplashView()
}
