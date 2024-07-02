import SwiftUI

struct TroupeDetailView: View {
    var troupe: Troupe
    @ObservedObject var UviewModel: UserViewModel
    @StateObject var TviewModel: TroupeViewModel = TroupeViewModel()
    var movies: [Movie] = [Movie(title: "capocchia"), Movie(title: "bianca"), Movie(title: "rossa"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca"), Movie(title: "bianca")]
    var navTitle: String
    var header: String
    
    var body: some View {
        VStack 
        {
            if let singleTroupe = TviewModel.singleTroupe {
                
                AsyncImageView(url: (singleTroupe.picture)!)
                    .frame(width: 200, height: 282.8)
                    .cornerRadius(8)
                    .shadow(radius: 4).aspectRatio(contentMode: .fill)
                
                Text(singleTroupe.full_name ?? "Unknown Actor")
                    .font(.largeTitle)
                    .padding()
                
                
                Text(header)
                    .font(.title2)
                    .padding()
                
                // Display the actor's movies
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 60) {
                        ForEach((singleTroupe.movies)!) { movie in
                            NavigationLink(destination: MovieView(UviewModel: UviewModel, movieId: movie._id!)) {
                                VStack {
                                    AsyncImageView(url: movie.poster!, movie: movie)
                                        .frame(width: 100, height: 141.4)
                                        .cornerRadius(8)
                                        .shadow(radius: 4).aspectRatio(contentMode: .fill)
                                    Text(movie.title!)
                                        .font(.caption)
                                }
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            Spacer()
        }
        .padding(.vertical, 20)
        .navigationTitle(navTitle + " Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{TviewModel.getTroupe(troupeId: troupe._id!)}
    }
}
