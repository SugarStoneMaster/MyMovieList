//
//  MovieInList.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import Foundation


class MovieInList: Movie
{
    var watched: Bool
    var favourite: Bool
    
    
    init(title: String, poster: String, overview: String, tagline: String, release_date: Date, release_year: Int, genres: [String], production_companies: [String], production_countries: [String], budget: Double, revenue: Double, runtime: Int, popularity: Double, status: String, vote_count: Int, vote_average: Double, actors: [Troupe], directors: [Troupe], spoken_languages: [String], watched_count: Int, added_count: Int, reviews: [Review], watched: Bool, favourite: Bool)
    {
        self.watched = watched
        self.favourite = favourite
        super.init(title: title, poster: poster, overview: overview, tagline: tagline, release_date: release_date, release_year: release_year, genres: genres, production_companies: production_companies, production_countries: production_countries, budget: budget, revenue: revenue, runtime: runtime, popularity: popularity, status: status, vote_count: vote_count, vote_average: vote_average, actors: actors, directors: directors, spoken_languages: spoken_languages, watched_count: watched_count, added_count: added_count, reviews: reviews)
    }
}
