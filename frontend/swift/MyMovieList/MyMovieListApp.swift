//
//  MyMovieListApp.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import SwiftUI

@main
struct MyMovieListApp: App {
    @StateObject var UviewModel = UserViewModel(user: User(_id: "66830877c52e5d1e2f042414", username: "pippotanto"))
    
    var body: some Scene {
        WindowGroup {
            ContentView(UviewModel: UviewModel)
        }
    }
}
