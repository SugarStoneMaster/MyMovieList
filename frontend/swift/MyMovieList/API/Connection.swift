//
//  API.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 17/06/24.
//

import Foundation
import Network

struct APIResponse: Codable {
    let message: String?
    let error: String?
}




var baseUrl: String = "http://192.168.1.237:5001/api/"



