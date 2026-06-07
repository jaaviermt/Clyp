//
//  AppAnimations.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

enum AppAnimations {
    static let tap:       Animation = .spring
    static let tapScale:  CGFloat   = 0.97

    static let favorites: Animation = .bouncy

    static let tabs:      Animation = .easeInOut(duration: 0.2)

    static let lists: AnyTransition = .opacity
        .combined(with: .move(edge: .bottom))
}
