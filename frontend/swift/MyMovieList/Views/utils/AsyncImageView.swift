//
//  AsyncImageView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 20/06/24.
//

import SwiftUI

struct AsyncImageView: View {
    @StateObject private var loader: AsyncImageLoader
    private let url: String

    init(url: String) {
        self.url = url
        _loader = StateObject(wrappedValue: AsyncImageLoader())
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ProgressView() // Show a loading indicator while the image is loading
            }
        }
        .onAppear {
            loader.loadImage(from: url)
        }
    }
}

#Preview {
    AsyncImageView(url: "")
}
