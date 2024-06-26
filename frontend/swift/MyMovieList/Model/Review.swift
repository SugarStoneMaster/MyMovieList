//
//  Review.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 10/06/24.
//

import Foundation


class Review: Identifiable, Codable
{
    var _id: String?
    var title: String?
    var content: String?
    var vote: Int?
    var user: User?
    var date: Date?
    
    enum CodingKeys: String, CodingKey {
            case _id
            case title
            case content
            case vote
            case user
            case date
        }
    
    init(_id: String? = nil, title: String? = nil, content: String? = nil, vote: Int? = nil, user: User? = nil, date: Date? = nil) {
        self._id = _id
        self.title = title
        self.content = content
        self.vote = vote
        self.user = user
        self.date = date
    }
    
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _id = try? container.decode(String.self, forKey: ._id)
            title = try? container.decode(String.self, forKey: .title)
            content = try? container.decode(String.self, forKey: .content)
            vote = try? container.decode(Int.self, forKey: .vote)
            user = try? container.decode(User.self, forKey: .user)
        
            
            let dateString = try? container.decode(String.self, forKey: .date)
            if let dateString = dateString {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                date = dateFormatter.date(from: dateString)
            }


        }
    
}
