//
//  User.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import Foundation


class User
{
    var username: String
    var email: String
    var password: String
    var movies_list: [MovieInList]
    
    
    init(username: String, email: String, password: String, movies_list: [MovieInList]) {
        self.username = username
        self.email = email
        self.password = password
        self.movies_list = movies_list
    }
    
}
