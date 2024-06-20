//
//  AsyncImageLoader.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 20/06/24.
//

import SwiftUI
import Combine

class AsyncImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?

    func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else {
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: imageURL)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }

    deinit {
        cancellable?.cancel()
    }
}
