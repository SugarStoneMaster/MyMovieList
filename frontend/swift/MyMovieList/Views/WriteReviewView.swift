import SwiftUI

struct WriteReviewView: View {
    @State private var title: String
    @State private var content: String
    @State private var vote: Int
    @ObservedObject var UviewModel: UserViewModel
    @ObservedObject var MviewModel: MovieViewModel
    var review: Review?
    @Environment(\.presentationMode) var presentationMode

    init(UviewModel: UserViewModel, MviewModel: MovieViewModel, review: Review? = nil) {
        self.UviewModel = UviewModel
        self.MviewModel = MviewModel
        self.review = review
        _title = State(initialValue: review?.title ?? "")
        _content = State(initialValue: review?.content ?? "")
        _vote = State(initialValue: review?.vote ?? 0)
    }

    var body: some View {
        VStack {
            Text(review == nil ? "Write a Review" : "Edit Review")
                .font(.title)
                .padding()
            TextField("Title", text: $title)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
            TextField("Content", text: $content)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
            HStack {
                Text("Rating:")
                StarsInputView(vote: $vote)
            }
            .padding()
            Button(action: {
                if let review = review {
                    UviewModel.updateReview(reviewId: review._id!, title: title, content: content, vote: vote)
                    {
                        MviewModel.getMovie(movieId: (MviewModel.singleMovie?._id)!)
                    }
                } else {
                    UviewModel.addReview(movieId: (MviewModel.singleMovie?._id)!, username: (UviewModel.user?.username)!, title: title, content: content, vote: vote) 
                    {
                        MviewModel.getMovie(movieId: (MviewModel.singleMovie?._id)!)
                    }
                }
                
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Submit")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .navigationTitle(review == nil ? "Write Review" : "Edit Review")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StarsInputView: View {
    @Binding var vote: Int
    var maximumRating = 5
    var onImage = "star.fill"
    var offImage = "star"
    var onColor = Color.yellow
    var offColor = Color.gray
    var starSize: CGFloat = 30  // Adjust this value to change the size

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1..<maximumRating + 1, id: \.self) { number in
                Image(systemName: number <= vote ? onImage : offImage)
                    .foregroundColor(number <= vote ? onColor : offColor)
                    .font(.system(size: starSize))  // Set the size of the star
                    .onTapGesture {
                        vote = number
                    }
            }
        }
    }
}
