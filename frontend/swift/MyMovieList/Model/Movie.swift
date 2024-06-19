//
//  Movie.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import Foundation


class Movie: Identifiable, Codable
{
    var _id: String?
    var title: String?
    var poster: String?
    var overview: String?
    var tagline: String?
    var release_date: Date?
    var release_year: Int?
    var genres: [String]?
    var production_companies: [String]?
    var production_countries: [String]?
    var budget: Double?
    var revenue: Double?
    var runtime: Int?
    var popularity: Double?
    var status: String?
    var vote_count: Int?
    var vote_average: Double?
    var actors: [Troupe]?
    var directors: [Troupe]?
    var spoken_languages: [String]?
    var watched_count: Int?
    var added_count: Int?
    var reviews: [Review]?
    var watched: Bool?
    var favourite: Bool?
    
    enum CodingKeys: String, CodingKey {
            case _id
            case title
            case poster
            case overview
            case tagline
            case release_date
            case release_year
            case genres
            case production_companies
            case production_countries
            case budget
            case revenue
            case runtime
            case popularity
            case status
            case vote_count
            case vote_average
            case actors
            case directors
            case spoken_languages
            case watched_count
            case added_count
            case reviews
            case watched
            case favourite
        }
    
    
    init(
            _id: String? = nil,
            title: String? = nil,
            poster: String? = nil,
            overview: String? = nil,
            tagline: String? = nil,
            release_date: Date? = nil,
            release_year: Int? = nil,
            genres: [String]? = nil,
            production_companies: [String]? = nil,
            production_countries: [String]? = nil,
            budget: Double? = nil,
            revenue: Double? = nil,
            runtime: Int? = nil,
            popularity: Double? = nil,
            status: String? = nil,
            vote_count: Int? = nil,
            vote_average: Double? = nil,
            actors: [Troupe]? = nil,
            directors: [Troupe]? = nil,
            spoken_languages: [String]? = nil,
            watched_count: Int? = nil,
            added_count: Int? = nil,
            reviews: [Review]? = nil,
            watched: Bool? = nil,
            favourite: Bool? = nil
        ) {
        self._id = _id
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
        self.watched = watched
        self.favourite = favourite
    }
    
    init() {
        
    }
    
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _id = try? container.decode(String.self, forKey: ._id)
            title = try? container.decode(String.self, forKey: .title)
            poster = try? container.decode(String.self, forKey: .poster)
            overview = try? container.decode(String.self, forKey: .overview)
            tagline = try? container.decode(String.self, forKey: .tagline)
            release_year = try? container.decode(Int.self, forKey: .release_year)
            genres = try? container.decode([String].self, forKey: .genres)
            production_companies = try? container.decode([String].self, forKey: .production_companies)
            production_countries = try? container.decode([String].self, forKey: .production_countries)
            budget = try? container.decode(Double.self, forKey: .budget)
            revenue = try? container.decode(Double.self, forKey: .revenue)
            runtime = try? container.decode(Int.self, forKey: .runtime)
            popularity = try? container.decode(Double.self, forKey: .popularity)
            status = try? container.decode(String.self, forKey: .status)
            vote_count = try? container.decode(Int.self, forKey: .vote_count)
            vote_average = try? container.decode(Double.self, forKey: .vote_average)
            actors = try? container.decode([Troupe].self, forKey: .actors)
            directors = try? container.decode([Troupe].self, forKey: .directors)
            spoken_languages = try? container.decode([String].self, forKey: .spoken_languages)
            watched_count = try? container.decode(Int.self, forKey: .watched_count)
            added_count = try? container.decode(Int.self, forKey: .added_count)
            reviews = try? container.decode([Review].self, forKey: .reviews)
            watched = try? container.decode(Bool.self, forKey: .watched)
            favourite = try? container.decode(Bool.self, forKey: .favourite)
            
            let releaseDateString = try? container.decode(String.self, forKey: .release_date)
            if let releaseDateString = releaseDateString {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                release_date = dateFormatter.date(from: releaseDateString)
            }
        }
    
}
