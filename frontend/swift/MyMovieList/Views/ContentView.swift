//
//  ContentView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import SwiftUI
import Network

struct ContentView: View {
    var body: some View 
    {
        TabView
        {
            MyMovieListView().tabItem
            {
                Image(systemName: "list.and.film")
                    .accessibilityAddTraits([.isButton])
                    .accessibilityLabel("My list")
                Text("My list")
            }
            
            ExploreView().tabItem
            {
                Image(systemName: "magnifyingglass")
                    .accessibilityAddTraits([.isButton])
                    .accessibilityLabel("Explore")
                Text("Explore")
            }
            
            ProfileView().tabItem
            {
                Image(systemName: "person.crop.circle")
                    .accessibilityAddTraits([.isButton])
                    .accessibilityLabel("Profile")
                Text("Profile")
            }
            
            
            
        }//end tab view
        
    }
}



#Preview {
    ContentView()
}
