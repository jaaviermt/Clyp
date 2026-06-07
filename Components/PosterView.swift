//
//  PosterView.swift
//  Clyp
//
//  Created by xav on 07/06/26.
//

import SwiftUI

struct PosterView: View {
    let imageURL: URL?

    init(imageURL: URL? = nil) {
        self.imageURL = imageURL
    }

    init(imageURLString: String?) {
        self.imageURL = imageURLString.flatMap(URL.init)
    }

    var body: some View {
        Group {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                            .overlay(ProgressView().tint(AppColors.ink))
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .aspectRatio(2.0 / 3.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    private var placeholder: some View {
        Image("Poster")
            .resizable()
            .scaledToFill()
    }
}
