//
//  ReviewView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 25/06/24.
//

import SwiftUI

struct ReviewView: View {
    let review: Review
    @ObservedObject var UviewModel: UserViewModel
    @ObservedObject var MviewModel: MovieViewModel
    @State private var showEditReview = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(review.title!)
                    .font(.headline)
                    .padding(.bottom, 2)
                
                Spacer()
                
                if review.user?.username == UviewModel.user?.username {
                    Button(action: {
                        showEditReview.toggle()
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showEditReview) {
                        WriteReviewView(UviewModel: UviewModel, MviewModel: MviewModel, review: review)
                    }
                }
            }
            
            Text(review.content!)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            HStack {
                StarsView(vote: review.vote!)
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

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter.string(from: date)
}
