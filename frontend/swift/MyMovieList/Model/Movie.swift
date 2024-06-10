//
//  Movie.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import Foundation


class Movie
{
    var title: String
    var poster: String
    var overview: String
    var tagline: String
    var release_date: Date
    var release_year: Int
    var genres: [String]
    var production_companies: [String]
    var production_countries: [String]
    var budget: Double
    var revenue: Double
    var runtime: Int
    var popularity: Double
    var status: String
    var vote_count: Int
    var vote_average: Double
    var actors: [Troupe]
    var directors: [Troupe]
    var spoken_languages: [String]
    var watched_count: Int
    var added_count: Int
    var reviews: [Review]
    
    
    init(title: String, poster: String, overview: String, tagline: String, release_date: Date, release_year: Int, genres: [String], production_companies: [String], production_countries: [String], budget: Double, revenue: Double, runtime: Int, popularity: Double, status: String, vote_count: Int, vote_average: Double, actors: [Troupe], directors: [Troupe], spoken_languages: [String], watched_count: Int, added_count: Int, reviews: [Review]) {
        self.title = title
        self.poster = poster
        self.overview = overview
        self.tagline = tagline
        self.release_date = release_date
        self.release_year = release_year
        self.genres = genres
        self.production_companies = production_companies
        self.production_countries = production_countries
        self.budget = budget
        self.revenue = revenue
        self.runtime = runtime
        self.popularity = popularity
        self.status = status
        self.vote_count = vote_count
        self.vote_average = vote_average
        self.actors = actors
        self.directors = directors
        self.spoken_languages = spoken_languages
        self.watched_count = watched_count
        self.added_count = added_count
        self.reviews = reviews
    }
    
}
