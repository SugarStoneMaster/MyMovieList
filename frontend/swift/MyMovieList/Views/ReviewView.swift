//
//  ReviewView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 25/06/24.
//

import SwiftUI

struct ReviewView: View 
{
    let review: Review
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            Text(review.title!)
                .font(.headline)
                .padding(.bottom, 2)
            
            Text(review.content!)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            HStack {
                StarsView(vote: review.vote!/2)
                Spacer()
                Text((review.user?.username)!)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Text(formatDate(review.date!))
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)
            
            Divider()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}




private func formatDate(_ date: Date) -> String
{
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter.string(from: date)
}
