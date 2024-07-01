//
//  MovieView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 21/06/24.
//

import SwiftUI

enum UserListState {
    case notInList
    case toWatch
    case watched
    
    mutating func toggle() {
            switch self {
            case .notInList:
                self = .toWatch
            case .toWatch:
                self = .watched
            case .watched:
                self = .notInList
            }
        }
}

enum FavoriteState {
    case notFavorite
    case favorite
    
    mutating func toggle() {
            switch self {
            case .notFavorite:
                self = .favorite
            case .favorite:
                self = .notFavorite
            }
        }
}





struct MovieView: View {
    @StateObject var MviewModel = MovieViewModel()
    @ObservedObject var UviewModel: UserViewModel
    let movieId: String

    @State private var userListState: UserListState = .notInList
    @State private var favoriteState: FavoriteState = .notFavorite

    var body: some View {
        NavigationStack {
            if let singleMovie = MviewModel.singleMovie {
                ScrollView(showsIndicators: false) {
                    VStack {
                        AsyncImageView(url: singleMovie.poster!, movie: singleMovie)
                            .frame(width: 200, height: 282.8)
                            .cornerRadius(8)
                            .shadow(radius: 4)

                        Text(singleMovie.title!)
                            .monospaced()
                            .padding(.top, 10)
                            .fontWeight(.heavy)

                        Text(singleMovie.tagline!)
                            .padding(.top, 3)
                            .italic()
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)

                        Text(singleMovie.getGenres())
                            .padding(.top, 3)
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                        

                        HStack(spacing: 40) {
                            VStack {
                                Button(action: toggleUserListState) {
                                    Image(systemName: userListIcon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .padding()
                                        .background(userListButtonColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 4)
                                }
                                Text(userListButtonText)
                                    .foregroundColor(.primary)
                                    .font(.caption)
                                    .padding(.top, 2)
                            }

                            VStack {
                                Button(action: toggleFavoriteState) {
                                    Image(systemName: favoriteState == .favorite ? "star.fill" : "star")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .padding()
                                        .background(favoriteButtonColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 4)
                                }
                                Text("Favourite")
                                    .foregroundColor(.primary)
                                    .font(.caption)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(.top, 10)

                        MainInfosMovieView(singleMovie: singleMovie)

                        HStack {
                            Text("Overview")
                                .font(.title)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)

                        Text(singleMovie.overview!)
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)

                        DirectorsView(UviewModel: UviewModel, directors: singleMovie.directors!)

                        CastView(UviewModel: UviewModel, actors: singleMovie.actors!)

                        OtherInfosView(companies: singleMovie.getCompanies(), languages: singleMovie.getLanguages())

                        FiveReviewsView(reviews: singleMovie.reviews ?? [], UviewModel: UviewModel, MviewModel: MviewModel)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .onAppear {
            MviewModel.getMovie(movieId: movieId)
            updateButtonStates()
        }
    }

    // Toggle user list state
    private func toggleUserListState() {
        userListState.toggle()
        if ((userListState == .notInList) || (userListState == .toWatch)) {
            favoriteState = .notFavorite
        }
        updateUserListInViewModel()
    }

    // Toggle favorite state
    private func toggleFavoriteState() {
        favoriteState.toggle()
        updateFavoriteInViewModel()
    }

    
    private func updateButtonStates() {
        if let movie = UviewModel.toWatchMovies.first(where: { $0._id == movieId }) {
            userListState = .toWatch
            favoriteState = .notFavorite
        }
        
        if let movie = UviewModel.watchedMovies.first(where: { $0._id == movieId }) {
            userListState = .watched
            favoriteState = .notFavorite
        }
        
        if let movie = UviewModel.favouriteMovies.first(where: { $0._id == movieId }) {
            userListState = .watched
            favoriteState = .favorite
        }
        
        
    }

    
    private func updateUserListInViewModel() {
        switch userListState {
        case .notInList:
            UviewModel.deleteMovieFromUserList(movieId: movieId)
        case .toWatch:
            UviewModel.addMovieToUserList(movieId: movieId, title: (MviewModel.singleMovie?.title)!, poster: (MviewModel.singleMovie?.poster)!, watched: false, favourite: false)
        case .watched:
            UviewModel.updateMovieInUserList(movieId: movieId, watched: true, favourite: false)
        }
    }

    
    private func updateFavoriteInViewModel() {
        var favoriteBool: Bool = false
        if(favoriteState == .favorite)
        {
            favoriteBool = true
        }
        if(favoriteState == .notFavorite)
        {
            favoriteBool = false
        }
        
        if(userListState == .notInList)
        {
            UviewModel.addMovieToUserList(movieId: movieId, title: (MviewModel.singleMovie?.title)!, poster: (MviewModel.singleMovie?.poster)!, watched: true, favourite: favoriteBool)
        }
        else
        {
            UviewModel.updateMovieInUserList(movieId: movieId, watched: true, favourite: favoriteBool)
        }
        
        if favoriteState == .favorite {
            userListState = .watched
        }
        
        UviewModel.getMoviesUserList(watched: true, favourite: true)
    }

    // Button text based on the user list state
    private var userListButtonText: String {
        switch userListState {
        case .notInList: return "Add to List"
        case .toWatch: return "To Watch"
        case .watched: return "Watched"
        }
    }
    
    // Button icon based on the user list state
        private var userListIcon: String {
            switch userListState {
            case .notInList: return "plus.circle"
            case .toWatch: return "clock"
            case .watched: return "checkmark.circle"
            }
        }

    // Button color based on the user list state
    private var userListButtonColor: Color {
        switch userListState {
        case .notInList: return .blue
        case .toWatch: return .orange
        case .watched: return .green
        }
    }

    // Favorite button color
    private var favoriteButtonColor: Color {
        return favoriteState == .favorite ? .yellow : .gray
    }
}





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

struct DirectorsView: View
{
    @ObservedObject var UviewModel: UserViewModel
    var directors: [Troupe]
    
    var body: some View
    {
        HStack
        {
            Text("Directed by").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Spacer()
        }.padding(.horizontal, 20).padding(.vertical, 20)
        
        HStack
        {
            VStack
            {
                NavigationLink(destination: TroupeDetailView(troupe: directors[0], UviewModel: UviewModel, navTitle: "Director", header: "Directed")) {
                    VStack {
                        Image("Zindre")
                            .resizable()
                            .frame(width: 100, height: 141)
                        Text(directors[0].full_name ?? "Unknown Director")
                            .padding(.horizontal, 0)
                    }
                    .padding(.horizontal)
                }.buttonStyle(PlainButtonStyle())
                
            }.padding(.vertical, 20)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8).frame(width: 200, height: 181)
            
            if(directors.count >= 2)
            {
                VStack
                {
                    NavigationLink(destination: TroupeDetailView(troupe: directors[1], UviewModel: UviewModel, navTitle: "Director", header: "Directed")) {
                        VStack {
                            Image("Zindre")
                                .resizable()
                                .frame(width: 100, height: 141)
                            Text(directors[1].full_name ?? "Unknown Director")
                                .padding(.horizontal, 30)
                        }
                        .padding(.horizontal)
                    }.buttonStyle(PlainButtonStyle())
                    
                }.padding(.vertical, 20)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8).frame(width: 200, height: 181)
            }
            
        }
    }
}


struct CastView: View
{
    @ObservedObject var UviewModel: UserViewModel
    var actors: [Troupe]
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Text("Cast").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer()
            }.padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false)
            {
                Divider().padding(.horizontal, 20)
                HStack
                {
                    Spacer()
                    Spacer()
                    HStack(spacing: 20)
                    {
                        ForEach(actors) 
                        { actor in
                                NavigationLink(destination: TroupeDetailView(troupe: actor, UviewModel: UviewModel, navTitle: "Actor", header: "Played in")) {
                                    VStack {
                                        Image("Zindre")
                                            .resizable()
                                            .frame(width: 100, height: 141)
                                        Text(actor.full_name ?? "Unknown Actor")
                                            .padding(.horizontal, 30)
                                    }
                                    .padding(.horizontal)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                
                Divider().padding(.horizontal, 20)
            }
        }.padding(.vertical, 40)
    }
}



struct FiveReviewsView: View
{
    let reviews: [Review]
    @State private var showAllReviews = false
    @State private var showWriteReview = false
    @ObservedObject var UviewModel: UserViewModel
    @ObservedObject var MviewModel: MovieViewModel

    

    var body: some View
    {
        VStack
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HStack {
                    Text("Reviews")
                        .font(.title)
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            
            VStack
            {
                ForEach(0..<reviews.count, id: \.self)
                { i in
                    ReviewView(review: reviews[i], UviewModel: UviewModel, MviewModel: MviewModel)
                }
                
                HStack
                {
                    NavigationLink(destination: AllReviewsView(MviewModel: MviewModel, UviewModel: UviewModel)) {
                        Text("Show All Reviews")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    
                    
                    
                    Spacer()
                    
                    Button(action: {
                        showWriteReview.toggle()
                    }) {
                        Text("Write a Review")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showWriteReview)
                    {
                        WriteReviewView(UviewModel: UviewModel, MviewModel: MviewModel)
                    }
                }
                
            }.padding(.horizontal, 20)
                .padding(.vertical, 10)
                .padding(.bottom, 20)
            
        }
    }
}

struct StarsView: View {
    var vote: Int
    var maximumRating = 5
    var onImage = "star.fill"
    var offImage = "star"
    var onColor = Color.yellow
    var offColor = Color.gray

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1..<maximumRating + 1, id: \.self) { number in
                Image(systemName: number <= vote ? onImage : offImage)
                    .foregroundColor(number <= vote ? onColor : offColor)
            }
        }
    }
}

struct OtherInfosView: View 
{
    var companies: String
    var languages: String
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            HStack
            {
                Text("Other infos").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer()
            }.padding(.horizontal, 20)
            
            
            VStack(alignment: .leading, spacing: 5)
                {
                    Text("Production companies: ")
                        .bold() + Text(companies)
                    
                    Text("Spoken languages: ")
                        .bold() + Text(languages)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            
        }
    }
}








