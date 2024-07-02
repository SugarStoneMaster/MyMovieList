//
//  AsyncImageView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 20/06/24.
//

import SwiftUI

struct AsyncImageView: View {
    @StateObject private var loader: AsyncImageLoader
    var movie: Movie?
    private let url: String

    init(url: String, movie: Movie? = nil) {
        self.url = url
        self.movie = movie
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
            if(movie != nil)
            {
                movie!.posterByte = loader.image
            }
        }
    }
}


