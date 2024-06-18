//
//  User.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import Foundation


class User: Identifiable, Codable
{
    var _id: String?
    var username: String
    var email: String?
    var password: String?
    var movies_list: [Movie]?
    
    
    init(_id: String? = nil, username: String, email: String? = nil, password: String? = nil, movies_list: [Movie]? = nil) {
        self._id = _id
        self.username = username
        self.email = email
        self.password = password
        self.movies_list = movies_list
    }
    
}
