//
//  AllReviewsView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 25/06/24.
//

import SwiftUI

//TODO SORTING REVIEWS
struct AllReviewsView: View
{
    @ObservedObject var MviewModel: MovieViewModel
    @ObservedObject var UviewModel: UserViewModel


    var body: some View {
        NavigationStack
        {
            VStack
            {
                //ForEach(0..<reviews.count, id: \.self)
                List(MviewModel.reviews)
                { review in
                    ReviewView(review: review, UviewModel: UviewModel, MviewModel: MviewModel)
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
