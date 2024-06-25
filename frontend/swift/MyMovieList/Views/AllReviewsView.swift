//
//  AllReviewsView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 25/06/24.
//

import SwiftUI

struct AllReviewsView: View 
{
    @ObservedObject var MviewModel: MovieViewModel


    var body: some View {
        NavigationStack
        {
            VStack
            {
                //ForEach(0..<reviews.count, id: \.self)
                List(MviewModel.reviews)
                { review in
                    ReviewView(review: review)
                }
            }
        }
            .navigationTitle("All Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                MviewModel.getMovieReviews()
            }
        
    }
}
