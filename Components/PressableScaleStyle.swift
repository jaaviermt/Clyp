//
//  PressableScaleStyle.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct PressableScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? AppAnimations.tapScale : 1)
            .animation(AppAnimations.tap, value: configuration.isPressed)
    }
}
