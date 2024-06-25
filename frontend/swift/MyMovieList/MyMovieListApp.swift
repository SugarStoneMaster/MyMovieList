//
//  MyMovieListApp.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import SwiftUI

@main
struct MyMovieListApp: App {
    @StateObject var UviewModel = UserViewModel(user: User(_id: "667590309c7bec2c21dcda9b", username: "pippotanto"))
    
    var body: some Scene {
        WindowGroup {
            ContentView(UviewModel: UviewModel)
        }
    }
}
