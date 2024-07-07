//
//  ExploreView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 20/06/24.
//

import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @ObservedObject var UviewModel: UserViewModel
    @StateObject var MviewModel = MovieViewModel()
    @State var loadeadAlready = false



    var body: some View 
    {
        NavigationStack
        {
            ScrollView(showsIndicators: false)
            {
                VStack
                {
                    SearchBar(text: $searchText, onSearch: { text in
                        if !text.isEmpty {
                            MviewModel.getMovies(text: text)
                        } else {
                            // Reset movies if search text is cleared
                            MviewModel.movies = []
                        }
                    }).padding(.top, 15).padding(.bottom, 20)
                    
                    if(searchText.isEmpty)
                    {
                        CategoryView(categoryName: "Populars", movies: MviewModel.popularMovies, UviewModel: UviewModel)
                        
                        CategoryView(categoryName: "Latest releases", movies: MviewModel.latestMovies, UviewModel: UviewModel)
                        
                        CategoryView(categoryName: "Most watched", movies: MviewModel.mostWatchedMovies, UviewModel: UviewModel)
                        
                        CategoryView(categoryName: "Adventure", movies: MviewModel.adventureMovies, UviewModel: UviewModel)
                        
                        CategoryView(categoryName: "Comedy", movies: MviewModel.comedyMovies, UviewModel: UviewModel)
                        
                        CategoryView(categoryName: "Thriller", movies: MviewModel.thrillerMovies, UviewModel: UviewModel)
                    }
                    else
                    {
                        FoundMoviesView(movies: MviewModel.movies, UviewModel: UviewModel)
                    }
                        
                    
                }

                
            }.navigationTitle("Explore").background(Color.black.opacity(0.9))
        }.onAppear
        {
            if(!loadeadAlready)
            {
                MviewModel.sortMovies(field: "popularity", order: -1)
                MviewModel.sortMovies(field: "release_date", order: -1)
                MviewModel.sortMovies(field: "watched_count", order: -1)
                MviewModel.getMoviesByGenres(genres: ["Adventure"])
                MviewModel.getMoviesByGenres(genres: ["Comedy"])
                MviewModel.getMoviesByGenres(genres: ["Thriller"])
            }
            
            loadeadAlready = true
        }
    }
}



struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    var onSearch: (String) -> Void

    var body: some View {
        HStack {
            TextField("Title, actor or director", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
                .onChange(of: text) { newValue in
                    onSearch(newValue)
                }

            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}


struct FoundMoviesView: View {
    var movies: [Movie]
    @ObservedObject var UviewModel: UserViewModel


    var body: some View {
        VStack {
            ForEach(movies) { movie in
                NavigationLink(destination: MovieView(UviewModel: UviewModel, movieId: movie._id!))
                {
                    HStack {
                        AsyncImageView(url: movie.poster ?? "", movie: movie)
                            .frame(width: 100, height: 150)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(movie.title ?? "Unknown Title")
                                .font(.headline)
                            
                            if let releaseYear = movie.release_year {
                                Text("Year: \(releaseYear)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            if let runtime = movie.runtime {
                                Text("Runtime: \(runtime) min")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            if let voteAverage = movie.vote_average {
                                Text("Rating: \(voteAverage, specifier: "%.1f")/10")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                }.buttonStyle(PlainButtonStyle())
                Divider()
            }
        }
    }
}


struct CategoryView: View {
    var categoryName: String
    var movies: [Movie]
    @ObservedObject var UviewModel: UserViewModel

    
    var body: some View 
    {
        VStack
        {
            HStack
            {
                Text(categoryName).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer()
            }.padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false)
            {
                HStack
                {
                    Spacer()
                    Spacer()
                    HStack(spacing: 20)
                    {
                        ForEach(movies)
                        { movie in
                            NavigationLink(destination: MovieView(UviewModel: UviewModel, movieId: movie._id!)) {
                                    VStack {
                                        if(movie.posterByte == nil)
                                        {
                                            AsyncImageView(url: movie.poster!, movie: movie)
                                                .frame(width: 100, height: 141)
                                        }
                                        else
                                        {
                                            Image(uiImage: movie.posterByte!).resizable()
                                                .aspectRatio(contentMode: .fill).frame(width: 100, height: 141)
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                
            }.padding(.vertical, -5)
        }.padding(.vertical, 15)
    }
}
