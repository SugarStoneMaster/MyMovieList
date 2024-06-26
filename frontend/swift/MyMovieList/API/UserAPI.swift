//
//  UserAPI.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 17/06/24.
//

import Foundation


class UserViewModel: ObservableObject
{
    var urlSub: String = "user/"
    

    
    @Published var movies: [Movie] = []
    @Published var reviews: [Review] = []
    @Published var user: User? = nil
    @Published var successMessage: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    init(user: User? = nil) {
        self.user = user
    }

    
    func appleSignIn(email: String, username: String)
    {
        guard let url = URL(string: baseUrl + urlSub + "apple_sign_in") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print(email)
        print(username)
        let body: [String: Any] = ["email": email, "username": username]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to encode JSON")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async {
                        self.user = user
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("HTTP request failed: \(error)")
            }
        }.resume()
    }
    
    
    func addMovieToUserList(movieId: String, title: String, poster: String, watched: Bool, favourite: Bool)
    {
        guard let url = URL(string: baseUrl + urlSub + "add_movie_to_user_list") else {
                    self.errorMessage = "Invalid URL"
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body: [String: Any] = [
                    "user_id": user!._id!,
                    "movie_id": movieId,
                    "title": title,
                    "poster": poster,
                    "watched": String(watched),
                    "favourite": String(favourite)
                ]

                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                } catch {
                    self.errorMessage = "Failed to encode JSON"
                    return
                }

                self.isLoading = true
                self.successMessage = nil
                self.errorMessage = nil

                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {

                        if let error = error {
                            self.errorMessage = "HTTP request failed: \(error.localizedDescription)"
                            return
                        }

                        guard let data = data else {
                            self.errorMessage = "No data received"
                            return
                        }

                    
                        if(self.errorMessage == nil)
                        {
                            var addedMovie = Movie()
                            addedMovie._id = movieId
                            addedMovie.title = title
                            addedMovie.poster = poster
                            addedMovie.watched = watched
                            addedMovie.favourite = favourite
                            self.movies.append(addedMovie)
                        }
                        
                        self.isLoading = false
                        
                    }
                }.resume()
    }
    
    
    func updateMovieInUserList(movieId: String, watched: Bool, favourite: Bool)
    {
        guard let url = URL(string: baseUrl + urlSub + "update_movie_in_user_list") else {
                    self.errorMessage = "Invalid URL"
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body: [String: Any] = [
                    "user_id": user!._id!,
                    "movie_id": movieId,
                    "watched": String(watched),
                    "favourite": String(favourite)
                ]

                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                } catch {
                    self.errorMessage = "Failed to encode JSON"
                    return
                }

                self.isLoading = true
                self.successMessage = nil
                self.errorMessage = nil

                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {

                        if let error = error {
                            self.errorMessage = "HTTP request failed: \(error.localizedDescription)"
                            return
                        }

                        guard let data = data else {
                            self.errorMessage = "No data received"
                            return
                        }

                    
                        /*
                        for movie in self.movies
                        {
                            if(movie._id == movieId)
                            {
                                movie.watched = watched
                                movie.favourite = favourite
                            }
                        }*/
                       
                        
                        self.isLoading = false
                        
                    }
                }.resume()
    }
    
    
    func deleteMovieFromUserList(movieId: String)
    {
        guard let url = URL(string: baseUrl + urlSub + "delete_movie_from_user_list/\(user!._id!)/\(movieId)") else {
                self.errorMessage = "Invalid URL"
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            self.isLoading = true
            self.errorMessage = nil
            self.successMessage = nil

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = "HTTP request failed: \(error.localizedDescription)"
                        return
                    }

                    guard let data = data else {
                        self.errorMessage = "No data received"
                        return
                    }

                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                        
                        if let error = apiResponse.error {
                            self.errorMessage = error
                        } else if let message = apiResponse.message {
                            self.successMessage = message
                            // Optionally, remove the movie from the movies array
                            self.movies.removeAll { $0._id == movieId }
                        }
                    } catch {
                        self.errorMessage = "Error decoding JSON: \(error.localizedDescription)"
                    }
                }
            }.resume()
        }
    
    
    
    func getMoviesUserList(watched: Bool, favourite: Bool)
    {
        guard let url = URL(string: baseUrl + urlSub + "get_movies_user_list/\(user!._id!)/\(watched)/\(favourite)") else {
               print("Invalid URL")
               return
           }
           
           print(url)
           URLSession.shared.dataTask(with: url) { (data, response, error) in
               if let data = data {
                   do {
                       let movies = try JSONDecoder().decode([Movie].self, from: data)
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
    
    
    func addReview(movieId: String, username: String, title: String, content: String, vote: Int)
    {
        guard let url = URL(string: baseUrl + urlSub + "add_review/\(movieId)") else {
                    self.errorMessage = "Invalid URL"
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body: [String: Any] = [
                    "username": username,
                    "user_id": user!._id!,
                    "title": title,
                    "content": content,
                    "vote": String(vote)
                ]

                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                } catch {
                    self.errorMessage = "Failed to encode JSON"
                    return
                }

                self.isLoading = true
                self.successMessage = nil
                self.errorMessage = nil

                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {

                        if let error = error {
                            self.errorMessage = "HTTP request failed: \(error.localizedDescription)"
                            return
                        }

                        guard let data = data else {
                            self.errorMessage = "No data received"
                            return
                        }

                    
                        if(self.errorMessage == nil)
                        {
                            var addedReview = Review(title: title, content: content,  vote: vote, user: User(_id: self.user!._id!, username: username))
                            self.reviews.append(addedReview)
                        }
                        
                        self.isLoading = false
                        
                    }
                }.resume()
    }
    
    
    func updateReview(reviewId: String, title: String, content: String, vote: Int)
    {
        guard let url = URL(string: baseUrl + urlSub + "update_review/\(reviewId)") else {
                    self.errorMessage = "Invalid URL"
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body: [String: Any] = [
                    "title": title,
                    "content": content,
                    "vote": String(vote)
                ]

                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                } catch {
                    self.errorMessage = "Failed to encode JSON"
                    return
                }

                self.isLoading = true
                self.successMessage = nil
                self.errorMessage = nil

                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {

                        if let error = error {
                            self.errorMessage = "HTTP request failed: \(error.localizedDescription)"
                            return
                        }

                        guard let data = data else {
                            self.errorMessage = "No data received"
                            return
                        }

                    
                        if(self.errorMessage == nil)
                        {
                            
                        }
                        
                        self.isLoading = false
                        
                    }
                }.resume()
    }
    
    
    

}


