//
//  AppTypography.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

enum AppTypography {
    static let displayXL = Font.system(size: 42, weight: .black)
    static let displayLG = Font.system(size: 38, weight: .black)
    static let displayMD = Font.system(size: 28, weight: .heavy)
    static let displaySM = Font.system(size: 20, weight: .heavy)

    static let body      = Font.system(size: 15, weight: .regular)
    static let bodySM    = Font.system(size: 13, weight: .regular)

    static let label     = Font.system(size: 14, weight: .bold)

    // Use with .textCase(.uppercase)
    static let eyebrow   = Font.system(size: 11, weight: .bold)
    static let chip      = Font.system(size: 10, weight: .bold)
    static let nav       = Font.system(size: 10, weight: .bold)
}
