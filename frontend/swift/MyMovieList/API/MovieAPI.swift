//
//  MovieAPI.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 17/06/24.
//

import Foundation


class MovieViewModel: ObservableObject
{
    var urlSub: String = "movies/"
    
    @Published var movies: [Movie] = []
    @Published var reviews: [Review] = []
    @Published var singleMovie: Movie? = nil
    
    @Published var adventureMovies: [Movie] = []
    @Published var comedyMovies: [Movie] = []
    @Published var thrillerMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    @Published var latestMovies: [Movie] = []
    @Published var mostWatchedMovies: [Movie] = []

    
    @Published var successMessage: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

   
    func getMovies(text: String)
    {
        guard let url = URL(string: baseUrl + urlSub + "get_movies/\(text)") else {
               print("Invalid URL")
               return
           }
           
           print(url)
           URLSession.shared.dataTask(with: url) { (data, response, error) in
               if let data = data {
                   do {
                       let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                       let moviesArray = json!["items"] as? [[String: Any]]
                       let jsonData = try JSONSerialization.data(withJSONObject: moviesArray, options: [])
                       let movies = try JSONDecoder().decode([Movie].self, from: jsonData)
                       DispatchQueue.main.async {
                           self.movies = movies
                       }
                   } catch {
                       print("Error decoding JSON: \(error)")
                   }
               } else if let error = error {
                   print("HTTP request failed: \(error)")
               }
           }.resume()
       }
    
    
    func getMoviesByGenres(genres: [String])
    {
        var urlComponents = URLComponents(string: baseUrl + urlSub + "get_movies_by_genres")!
            urlComponents.queryItems = genres.map { URLQueryItem(name: "genres", value: $0) }
            guard let url = urlComponents.url else {
                print("Invalid URL")
                return
            }
           
           print(url)
           URLSession.shared.dataTask(with: url) { (data, response, error) in
               if let data = data {
                   do {
                       let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                       let moviesArray = json!["items"] as? [[String: Any]]
                       let jsonData = try JSONSerialization.data(withJSONObject: moviesArray, options: [])
                       let movies = try JSONDecoder().decode([Movie].self, from: jsonData)
                       DispatchQueue.main.async {
                           if(genres[0] == "Adventure")
                           {
                               self.adventureMovies = movies
                           }
                           if(genres[0] == "Comedy")
                           {
                               self.comedyMovies = movies
                           }
                           if(genres[0] == "Thriller")
                           {
                               self.thrillerMovies = movies
                           }
                           self.movies = movies
                       }
                   } catch {
                       print("Error decoding JSON: \(error)")
                   }
               } else if let error = error {
                   print("HTTP request failed: \(error)")
               }
           }.resume()
       }
    
    
    func getMoviesByReleaseYear(year: Int) 
    {
        guard let url = URL(string: baseUrl + urlSub + "release_year/\(year)") else {
               print("Invalid URL")
               return
           }
           
           print(url)
           URLSession.shared.dataTask(with: url) { (data, response, error) in
               if let data = data {
                   do {
                       let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                       let moviesArray = json!["items"] as? [[String: Any]]
                       let jsonData = try JSONSerialization.data(withJSONObject: moviesArray, options: [])
                       let movies = try JSONDecoder().decode([Movie].self, from: jsonData)
                       DispatchQueue.main.async {
                           self.movies = movies
                       }
                   } catch {
                       print("Error decoding JSON: \(error)")
                   }
               } else if let error = error {
                   print("HTTP request failed: \(error)")
               }
           }.resume()
       }
    
    
    func sortMovies(field: String, order: Int)
    {
        guard let url = URL(string: baseUrl + urlSub + "sort/\(field)/\(order)") else {
               print("Invalid URL")
               return
           }
           
           print(url)
           URLSession.shared.dataTask(with: url) { (data, response, error) in
               if let data = data {
                   do {
                       let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                       let moviesArray = json!["items"] as? [[String: Any]]
                       let jsonData = try JSONSerialization.data(withJSONObject: moviesArray, options: [])
                       let movies = try JSONDecoder().decode([Movie].self, from: jsonData)
                       DispatchQueue.main.async {
                           if(field == "release_date")
                           {
                               self.latestMovies = movies
                           }
                           if(field == "popularity")
                           {
                               self.popularMovies = movies
                           }
                           if(field == "watched_count")
                           {
                               self.mostWatchedMovies = movies
                           }
                           self.movies = movies
                       }
                   } catch {
                       print("Error decoding JSON: \(error)")
                   }
               } else if let error = error {
                   print("HTTP request failed: \(error)")
               }
           }.resume()
       }
    
    
    func getMovieReviews()
    {
        guard let url = URL(string: baseUrl + urlSub + "reviews/\(singleMovie!._id!)") else {
               print("Invalid URL")
               return
           }
           
           print(url)
           URLSession.shared.dataTask(with: url) { (data, response, error) in
               if let data = data {
                   do {
                       // Parse JSON data
                       let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                       guard let reviewsArray = json?["items"] as? [[String: Any]] else {
                           print("Failed to parse reviews")
                           return
                       }
                       
                       // Encode the array of dictionaries back to JSON data
                       let jsonData = try JSONSerialization.data(withJSONObject: reviewsArray, options: [])
                       
                       // Decode the JSON data to an array of Review objects
                       let reviews = try JSONDecoder().decode([Review].self, from: jsonData)
                       
                       DispatchQueue.main.async {
                           self.reviews = reviews // Make sure `self.reviews` is defined and accessible
                       }
                   } catch {
                       print("Error decoding JSON: \(error)")
                   }
               } else if let error = error {
                   print("HTTP request failed: \(error)")
               }
           }.resume()
       }
    
    
    func getMovie(movieId: String)
    {
        guard let url = URL(string: baseUrl + urlSub + "get_movie/\(movieId)") else {
               print("Invalid URL")
               return
           }
           
           print(url)
           URLSession.shared.dataTask(with: url) { (data, response, error) in
               if let data = data {
                   do {
                       let singleMovie = try JSONDecoder().decode(Movie.self, from: data)
                       DispatchQueue.main.async {
                           self.singleMovie = singleMovie
                       }
                   } catch {
                       print("Error decoding JSON: \(error)")
                   }
               } else if let error = error {
                   print("HTTP request failed: \(error)")
               }
           }.resume()
       }
    
    
    
    

}


