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
    @State private var watched = false
    @ObservedObject var UviewModel: UserViewModel

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    FilterPicker(selectedFilter: $selectedFilter)

                    TabView(selection: $selectedFilter) {
                        MovieGrid(UviewModel: UviewModel, selectedFilter: .constant(.toWatch), isFavoriteFilterActive: $isFavoriteFilterActive)
                            .tag(MovieFilter.toWatch)
                            .background(Color(uiColor: .systemGray6))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        
                        MovieGrid(UviewModel: UviewModel, selectedFilter: .constant(.watched), isFavoriteFilterActive: $isFavoriteFilterActive)
                            .tag(MovieFilter.watched)
                            .background(Color(uiColor: .systemGray6))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onChange(of: selectedFilter) { newFilter in
                        watched = (newFilter == .watched)
                    }
                }
                .background(Color(uiColor: .systemGray6))
                .navigationTitle("My List")
                .onAppear {
                    UviewModel.getMoviesUserList(watched: false, favourite: false)
                    UviewModel.getMoviesUserList(watched: true, favourite: false)
                    UviewModel.getMoviesUserList(watched: true, favourite: true)
                }

                if selectedFilter == .watched {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                isFavoriteFilterActive.toggle()
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
    @ObservedObject var UviewModel: UserViewModel
    @Binding var selectedFilter: MovieFilter
    @Binding var isFavoriteFilterActive: Bool

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                LazyVGrid(columns: [GridItem(.fixed(90), spacing: 20),
                                    GridItem(.fixed(90), spacing: 20),
                                    GridItem(.fixed(90), spacing: 20)], spacing: 10) {
                    if(selectedFilter == .toWatch)
                    {
                        ForEach(UviewModel.toWatchMovies) { movie in
                            VStack {
                                NavigationLink(destination: MovieView(UviewModel: UviewModel, movieId: movie._id!), label: {
                                    VStack {
                                        AsyncImageView(url: movie.poster!, movie: movie)
                                            .frame(width: 100, height: 141.4) // Adjust the size as needed
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                    }
                                })
                            }
                        }
                    }
                    else if(selectedFilter == .watched && !isFavoriteFilterActive)
                    {
                        ForEach(UviewModel.watchedMovies) { movie in
                            VStack {
                                NavigationLink(destination: MovieView(UviewModel: UviewModel, movieId: movie._id!), label: {
                                    VStack {
                                        AsyncImageView(url: movie.poster!, movie: movie)
                                            .frame(width: 100, height: 141.4) // Adjust the size as needed
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                    }
                                })
                            }
                        }
                    }
                    else if(isFavoriteFilterActive)
                    {
                        ForEach(UviewModel.favouriteMovies) { movie in
                            VStack {
                                NavigationLink(destination: MovieView(UviewModel: UviewModel, movieId: movie._id!), label: {
                                    VStack {
                                        AsyncImageView(url: movie.poster!, movie: movie)
                                            .frame(width: 100, height: 141.4) // Adjust the size as needed
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                    }
                                })
                            }
                        }
                    }
                    
                }
                .padding(.top, 10)
                .padding(.bottom, 50) // Add padding at the bottom
            }
            .padding(.horizontal)
        }
    }
}

