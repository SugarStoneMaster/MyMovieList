//
//  MyMovieListApp.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import SwiftUI

@main
struct MyMovieListApp: App {
    @StateObject var UviewModel = UserViewModel(user: User(_id: "667d0d746a939c2772cf4a86", username: "pippotanto"))
    
    var body: some Scene {
        WindowGroup {
            ContentView(UviewModel: UviewModel)
        }
    }
}
