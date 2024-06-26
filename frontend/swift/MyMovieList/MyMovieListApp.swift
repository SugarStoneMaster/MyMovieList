//
//  MyMovieListApp.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import SwiftUI

@main
struct MyMovieListApp: App {
    @StateObject var UviewModel = UserViewModel(user: User(_id: "667aef39b0c20f4c953d9efe", username: "pippotanto"))
    
    var body: some Scene {
        WindowGroup {
            ContentView(UviewModel: UviewModel)
        }
    }
}
