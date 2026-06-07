//
//  AppColors.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

enum AppColors {
    static let cream         = Color(hex: 0xFFF7E6)
    static let ink           = Color(hex: 0x111111)
    static let clypOrange    = Color(hex: 0xFF4D00)
    static let silverScreen  = Color(hex: 0xE5E1DA)
    static let sunbeam       = Color(hex: 0xFFC700)
    static let indigoFrame   = Color(hex: 0x2A5BFF)
    static let euphoria      = Color(hex: 0x00C2A8)
    static let heartbeat     = Color(hex: 0xFF2FA0)
    static let voltPurple    = Color(hex: 0x7A2CFF)
}

private extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8)  & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
