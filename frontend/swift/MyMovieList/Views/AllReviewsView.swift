//
//  AllReviewsView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 25/06/24.
//

import SwiftUI

struct AllReviewsView: View 
{
    let reviews: [Review]

    var body: some View {
        NavigationStack
        {
            VStack
            {
                //ForEach(0..<reviews.count, id: \.self)
                List(reviews)
                { review in
                    ReviewView(review: review)
                }
            }
        }
            .navigationTitle("All Reviews")
            .navigationBarTitleDisplayMode(.inline)
    }
}
