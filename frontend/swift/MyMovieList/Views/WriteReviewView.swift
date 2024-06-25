import SwiftUI

struct WriteReviewView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var vote: Int = 0
    var UviewModel: UserViewModel
    var MviewModel: MovieViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Write a Review")
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
                UviewModel.addReview(movieId: (MviewModel.singleMovie?._id)!, username: (UviewModel.user?.username)!, title: title, content: content, vote: vote)
                presentationMode.wrappedValue.dismiss() // Close the modal
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
        .navigationTitle("Write Review")
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
