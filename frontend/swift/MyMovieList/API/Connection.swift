//
//  API.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 17/06/24.
//

import Foundation

struct APIResponse: Codable {
    let message: String?
    let error: String?
}

var baseUrl = URLComponents(string: "http://127.0.0.1:5000/api/" )
