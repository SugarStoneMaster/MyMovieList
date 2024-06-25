//
//  MainInfosMovieView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 25/06/24.
//

import SwiftUI

struct MainInfosMovieView: View {
    var singleMovie: Movie
    
    var body: some View
    {
        ScrollView(.horizontal, showsIndicators: false)
        {
            Divider().padding(.horizontal, 20)
            HStack
            {
                Spacer()
                Spacer()
                HStack(spacing: 20)
                {
                    VStack
                    {
                        Text("Vote").bold()
                        Text(String(format: "%.1f", singleMovie.vote_average!))
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    VStack
                    {
                        Text("Year").bold()
                        Text(String(singleMovie.release_year!))
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    VStack
                    {
                        Text("Runtime").bold()
                        Text("\(singleMovie.runtimeHour())")
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    VStack
                    {
                        Text("Popularity").bold()
                        Text("\(singleMovie.popularity!)")
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    VStack
                    {
                        Text("Budget").bold()
                        Text("$\(singleMovie.budget!/1000000)M")
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    VStack
                    {
                        Text("Revenue").bold()
                        Text("$\(singleMovie.revenue!/1000000)M")
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            Divider().padding(.horizontal, 20)
        }.padding(.top, 20)

    }
}


