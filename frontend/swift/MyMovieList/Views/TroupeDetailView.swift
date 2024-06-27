import SwiftUI

struct TroupeDetailView: View {
    var troupe: Troupe
    @ObservedObject var UviewModel: UserViewModel
    var movies: [Movie] = [Movie(title: "capocchia"), Movie(title: "bianca"), Movie(title: "rossa"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca")]

    var body: some View {
        VStack {
            
            Image("Zindre")
                .frame(width: 200, height: 282.8)
                .cornerRadius(8)
                .shadow(radius: 4)
            
            Text(troupe.full_name ?? "Unknown Actor")
                .font(.largeTitle)
                .padding()

            // Display the actor's movies
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 45) {
                    ForEach(movies) { movie in
                        NavigationLink(destination: MovieView(UviewModel: UviewModel, movieId: "667b1d9841f7110754a939e7")) {
                            VStack {
                                Image("Zindre")
                                    .frame(width: 100, height: 141.4)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                                Text(movie.title!)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Actor Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
