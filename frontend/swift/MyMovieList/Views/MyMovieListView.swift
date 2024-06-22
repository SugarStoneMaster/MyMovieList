import SwiftUI

enum MovieFilter: String, CaseIterable, Identifiable {
    case toWatch = "To Watch"
    case watched = "Watched"
    
    var id: String { self.rawValue }
}

struct MyMovieListView: View {
    @State private var showingSheet = false
    @State private var selectedFilter: MovieFilter = .toWatch
    @State private var isFavoriteFilterActive = false
    @StateObject private var viewModel = UserViewModel()
    @State private var userId = "667590309c7bec2c21dcda9b"
    
    var filteredMovies: [Movie] {
        switch selectedFilter {
        case .toWatch:
            return viewModel.movies.filter { !$0.watched! }
        case .watched:
            return viewModel.movies.filter {
                if isFavoriteFilterActive {
                    return $0.watched! && $0.favourite!
                } else {
                    return $0.watched!
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    FilterPicker(selectedFilter: $selectedFilter)
                    
                    MovieGrid(filteredMovies: filteredMovies)

                }
                .background(Color.gray)
                .navigationTitle("My List")
                .onAppear {
                    viewModel.getMoviesUserList(userId: userId, watched: selectedFilter == .watched, favourite: isFavoriteFilterActive)
                }
                .onChange(of: selectedFilter) { newFilter in
                    viewModel.getMoviesUserList(userId: userId, watched: newFilter == .watched, favourite: isFavoriteFilterActive)
                }

                if selectedFilter == .watched {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                isFavoriteFilterActive.toggle()
                                viewModel.getMoviesUserList(userId: userId, watched: true, favourite: isFavoriteFilterActive)
                            }) {
                                Image(systemName: isFavoriteFilterActive ? "star.fill" : "star")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(isFavoriteFilterActive ? Color.yellow : Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 18).padding(.vertical, 50)
                        }
                    }
                }
            }
        }
    }
}

struct FilterPicker: View {
    @Binding var selectedFilter: MovieFilter

    var body: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(MovieFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

struct MovieGrid: View {
    var filteredMovies: [Movie]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                LazyVGrid(columns: [GridItem(.fixed(90), spacing: 20),
                                    GridItem(.fixed(90), spacing: 20),
                                    GridItem(.fixed(90), spacing: 20)], spacing: 10) {
                    ForEach(filteredMovies) { movie in
                        VStack {
                            NavigationLink(destination: MovieView(movieId: movie._id!), label: {
                                VStack {
                                    AsyncImageView(url: movie.poster!)
                                        .frame(width: 100, height: 141.4) // Adjust the size as needed
                                        .cornerRadius(8)
                                        .shadow(radius: 4)
                                }
                            })
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    MyMovieListView()
}
