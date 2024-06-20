//
//  MainView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 17/06/24.
//

import SwiftUI

struct TestView: View
{
    @StateObject private var viewModel = UserViewModel()
    @StateObject private var MviewModel = MovieViewModel()
    @StateObject private var TviewModel = TroupeViewModel()


    
    @State private var userId: String = "6672cb48bdacc9431ece7870"
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
                    /*Button(action: {
                                viewModel.addMovieToUserList(userId: userId, movieId: movieId, title: title, poster: poster, watched: watched, favourite: favourite)
                            }) {
                                Text("Add Movie to userlist")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                                viewModel.updateMovieInUserList(userId: userId, movieId: movieId, watched: watched, favourite: favourite)
                            }) {
                                Text("Update Movie in userlist")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                                viewModel.deleteMovieFromUserList(userId: userId, movieId: movieId)
                            }) {
                                Text("Delete Movie from user list")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                                viewModel.addReview(movieId: movieId, username: "nuova", userId: userId, title: "nuovisima", content: "ciao", vote: 10)
                            }) {
                                Text("Add Review to movie")
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
                            }*/
                    
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
/*
                    List(viewModel.reviews)
                    { review in
                        VStack(alignment: .leading)
                        {
                            Text(review.title ?? "No Title").font(.headline)
                            Text(review.content ?? "No Title").font(.headline)

                        }
                    }
                    
                    Button(action: {
                        MviewModel.getMoviesByReleaseYear(year: 2001)
                            }) {
                                Text("Movies in year")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                        MviewModel.sortMovies(field: "popularity", order: -1)
                            }) {
                                Text("Movies in order")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                        MviewModel.getMoviesByGenres(genres: ["Family", "Animation"])
                            }) {
                                Text("Movies by genres")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                        MviewModel.getMovieReviews(movieId: "6672cb48bdacc9431ece67c9")
                            }) {
                                Text("Movies reviews")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    List(MviewModel.movies)
                    { movie in
                        VStack(alignment: .leading)
                        {
                            Text(movie.title ?? "No Title").font(.headline)
                            Text("Watched: \(movie.watched == true ? "Yes" : "No")")
                        }
                    }
                    
                    List(MviewModel.reviews)
                    { review in
                        VStack(alignment: .leading)
                        {
                            Text(review.title ?? "No Title").font(.headline)
                        }
                    }
                    
                    Button(action: {
                        MviewModel.getMovie(movieId: "6672cb48bdacc9431ece67c9")
                            }) {
                                Text("Get movie")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                    Button(action: {
                        TviewModel.getTroupe(troupeId: "6672cb48bdacc9431ece6827")
                            }) {
                                Text("Get troupe")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }*/
                    VStack
                    {
                        if(MviewModel.singleMovie != nil)
                        {
                            Text(MviewModel.singleMovie!.title!)
                            Text(MviewModel.singleMovie!.overview!)
                        }
                    }
                    
                    VStack
                    {
                        if(TviewModel.singleTroupe != nil)
                        {
                            Text(TviewModel.singleTroupe!.full_name!)
                            Text(TviewModel.singleTroupe!.type!)
                        }
                    }
                    
                }//VStack end
                
                        .navigationTitle("Movies")
                        .onAppear{viewModel.getMoviesUserList(userId: userId, watched: watched)}
                    }
        }
}

#Preview {
    TestView()
}
