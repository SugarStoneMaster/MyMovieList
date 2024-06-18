//
//  MainView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 17/06/24.
//

import SwiftUI

struct MainView: View 
{
    @StateObject private var viewModel = UserViewModel()
    
    @State private var userId: String = "66698002ac0322a05e462d2a"
    @State private var movieId: String = "66698002ac0322a05e461c7a"
    @State private var title: String = "American Beauty"
    @State private var poster: String = "https://m.media-amazon.com/images/M/MV5BNTBmZWJkNjctNDhiNC00MGE2LWEwOTctZTk5OGVhMWMyNmVhXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_SX300.jpg"
    @State private var watched: Bool = false
    @State private var favourite: Bool = false

        
        var body: some View 
        {
            NavigationView 
            {
                VStack
                {
                    if viewModel.isLoading
                    {
                        ProgressView("Loading...")
                    }
                    else if let errorMessage = viewModel.errorMessage
                    {
                        Text(errorMessage).foregroundColor(.red)
                    }
                    else
                    {
                        List(viewModel.movies)
                        { movie in
                            VStack(alignment: .leading)
                            {
                                Text(movie.title ?? "No Title").font(.headline)
                                Text("Watched: \(movie.watched == true ? "Yes" : "No")")
                            }
                        }
                     }
                    Button(action: {
                                viewModel.addMovieToUserList(userId: userId, movieId: movieId, title: title, poster: poster, watched: watched, favourite: favourite)
                            }) {
                                Text("Add Movie")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                                viewModel.updateMovieInUserList(userId: userId, movieId: movieId, watched: watched, favourite: favourite)
                            }) {
                                Text("Update Movie")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                                viewModel.deleteMovieFromUserList(userId: userId, movieId: movieId)
                            }) {
                                Text("Delete Movie")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                                viewModel.addReview(movieId: movieId, username: "nuova", userId: userId, title: "nuovisima", content: "ciao", vote: 10)
                            }) {
                                Text("Add Review")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                                viewModel.updateReview(reviewId: "66717ce2e1138b351b823f2c", title: "nuova modificata", content: "ho modificatooo", vote: 7)
                            }) {
                                Text("Update Review")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    
                    Button(action: {
                        watched.toggle()
                        viewModel.getMoviesUserList(userId: userId, watched: watched)
                            }) {
                                Text("Watched")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }

                    List(viewModel.reviews)
                    { review in
                        VStack(alignment: .leading)
                        {
                            Text(review.title ?? "No Title").font(.headline)
                            Text(review.content ?? "No Title").font(.headline)

                        }
                    }
                    
                }//VStack end
                
                        .navigationTitle("Movies")
                        .onAppear{viewModel.getMoviesUserList(userId: userId, watched: watched)}
                    }
        }
}

#Preview {
    MainView()
}
