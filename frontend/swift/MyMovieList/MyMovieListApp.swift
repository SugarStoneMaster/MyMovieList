//
//  MyMovieListApp.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import SwiftUI

@main
struct MyMovieListApp: App {
    @StateObject var UviewModel = UserViewModel(user: User(_id: "667b1d9841f7110754a94a7e", username: "pippotanto"))
    
    var body: some Scene {
        WindowGroup {
            ContentView(UviewModel: UviewModel)
        }
    }
}
