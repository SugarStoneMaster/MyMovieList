//
//  Troupe.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import Foundation


class Troupe: Identifiable, Codable
{
    var _id: String?
    var full_name: String?
    var picture: String?
    var type: String?
    var movies: [Movie]?
    
    init(_id: String? = nil, full_name: String? = nil, picture: String? = nil, type: String? = nil, movies: [Movie]? = nil) {
        self._id = _id
        self.full_name = full_name
        self.picture = picture
        self.type = type
        self.movies = movies
    }
}
