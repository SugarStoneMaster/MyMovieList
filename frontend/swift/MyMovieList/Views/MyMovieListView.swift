import SwiftUI

enum MovieFilter: String, CaseIterable, Identifiable {
    case toWatch = "To Watch"
    case watched = "Watched"
    
    var id: String { self.rawValue }
}

struct MyMovieListView: View {
    @State private var showingSheet = false
    @State private var selectedFilter: MovieFilter = .toWatch
    @StateObject private var viewModel = UserViewModel()
    
    var filteredMovies: [Movie] {
        switch selectedFilter {
        case .toWatch:
            return viewModel.movies.filter { !$0.watched! }
        case .watched:
            return viewModel.movies.filter { $0.watched! }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(MovieFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        LazyVGrid(columns: [GridItem(.fixed(90), spacing: 20),
                                            GridItem(.fixed(90), spacing: 20),
                                            GridItem(.fixed(90), spacing: 20)], spacing: 10) {
                            ForEach(filteredMovies) { movie in
                                VStack {
                                    Button(action: {
                                        print("DEBUG: selected movie with title:\(movie.title)")
                                    }) {
                                        VStack {
                                            AsyncImageView(url: movie.poster!)
                                                .frame(width: 100, height: 141.4) // Adjust the size as needed
                                                .cornerRadius(8)
                                                .shadow(radius: 4)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.gray)
            .navigationTitle("My List")
            .onAppear {
                viewModel.getMoviesUserList(userId: "6672cb48bdacc9431ece7870", watched: selectedFilter == .watched)
            }
            .onChange(of: selectedFilter) { newFilter in
                viewModel.getMoviesUserList(userId: "6672cb48bdacc9431ece7870", watched: newFilter == .watched)
            }
        }
    }
}

#Preview {
    MyMovieListView()
}
