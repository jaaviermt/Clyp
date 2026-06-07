//
//  Mood+Theme.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

extension Mood {
    var color: Color {
        switch name.lowercased() {
        case "happy":     return AppColors.sunbeam
        case "sad":       return AppColors.indigoFrame
        case "excited":   return AppColors.euphoria
        case "romantic":  return AppColors.heartbeat
        case "tense":     return AppColors.voltPurple
        case "nostalgic": return AppColors.clypOrange
        default:          return AppColors.clypOrange
        }
    }

    // Returns ink or cream depending on which gives readable contrast
    // against the mood color. Only DS colors are used.
    var foregroundOnColor: Color {
        switch name.lowercased() {
        case "sad", "tense": return AppColors.cream
        default:             return AppColors.ink
        }
    }

    var iconAssetName: String? {
        switch name.lowercased() {
        case "happy":     return "Happy"
        case "sad":       return "Sad"
        case "excited":   return "Excited"
        case "romantic":  return "Romantic"
        case "tense":     return "Tense"
        case "nostalgic": return "Nostalgic"
        default:          return nil
        }
    }
}
