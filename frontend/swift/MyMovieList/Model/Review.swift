//
//  Review.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import Foundation


class Review
{
    var title: String
    var content: String
    var date: Date
    var vote: Double
    var user: User
    
    
    init(title: String, content: String, date: Date, vote: Double, user: User) {
        self.title = title
        self.content = content
        self.date = date
        self.vote = vote
        self.user = user
    }
    
}
