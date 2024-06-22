//
//  MovieView.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 21/06/24.
//

import SwiftUI

struct MovieView: View {
    @StateObject private var viewModel = MovieViewModel()
    let movieId: String

    var body: some View {
        NavigationStack {
            if viewModel.singleMovie != nil {
                ScrollView (showsIndicators: false)
                {
                    VStack 
                    {
                        AsyncImageView(url: viewModel.singleMovie!.poster!)
                            .frame(width: 200, height: 282.8)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                        
                        Text(viewModel.singleMovie!.title!)
                            .monospaced()
                            .padding(.top, 10).fontWeight(Font.Weight.heavy)
                        
                        
                        Text(viewModel.singleMovie!.tagline!)
                            .padding(.top, 3).italic().padding(.horizontal, 15).multilineTextAlignment(.center)
                        
                        Text(viewModel.singleMovie!.getGenres())
                            .padding(.top, 3).padding(.horizontal, 15).multilineTextAlignment(.center)
                        
                        
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) 
                        {
                            Divider().padding(.horizontal, 20)
                            HStack
                            {
                                Spacer()
                                Spacer()
                                HStack(spacing: 20) 
                                {
                                    VStack 
                                    {
                                        Text("Vote").bold()
                                        Text(String(format: "%.1f", viewModel.singleMovie!.vote_average!))
                                    }
                                    .padding(.horizontal)
                                    
                                    Divider()
                                    
                                    VStack 
                                    {
                                        Text("Year").bold()
                                        Text(String(viewModel.singleMovie!.release_year!))
                                    }
                                    .padding(.horizontal)
                                    
                                    Divider()
                                    
                                    VStack 
                                    {
                                        Text("Runtime").bold()
                                        Text("\(viewModel.singleMovie!.runtimeHour())")
                                    }
                                    .padding(.horizontal)
                                    
                                    Divider()
                                    
                                    VStack
                                    {
                                        Text("Popularity").bold()
                                        Text("\(viewModel.singleMovie!.popularity!)")
                                    }
                                    .padding(.horizontal)
                                    
                                    Divider()
                                    
                                    VStack 
                                    {
                                        Text("Budget").bold()
                                        Text("$\(viewModel.singleMovie!.budget!/1000000)M")
                                    }
                                    .padding(.horizontal)
                                    
                                    Divider()
                                    
                                    VStack 
                                    {
                                        Text("Revenue").bold()
                                        Text("$\(viewModel.singleMovie!.revenue!/1000000)M")
                                    }
                                    .padding(.horizontal)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            Divider().padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        HStack
                        {
                            Text("Overview").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            Spacer()
                        }.padding(.horizontal, 20).padding(.vertical, 10)
                        
                        Text(viewModel.singleMovie!.overview!).padding(.horizontal, 15).multilineTextAlignment(.center)
                        
                        HStack 
                        {
                            Text("Directed by").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            Spacer()
                        }.padding(.horizontal, 20).padding(.vertical, 20)
                        
                        HStack
                        {
                            VStack
                            {
                                Image("Zindre").resizable().frame(width: 100, height: 141)
                                HStack 
                                {
                                    Text((viewModel.singleMovie?.directors![0].full_name)!)
                                }.padding(.horizontal, 20)
                                
                            }.padding(.vertical, 20)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8).frame(width: 200, height: 181)
                            
                            if((viewModel.singleMovie?.directors!.count)! >= 2)
                            {
                                VStack
                                {
                                    Image("Zindre").resizable().frame(width: 100, height: 141)
                                    HStack
                                    {
                                        Text((viewModel.singleMovie?.directors![0].full_name)!)
                                    }.padding(.horizontal, 20)
                                    
                                }.padding(.vertical, 20)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8).frame(width: 200, height: 181)
                            }
                            
                        }
                        
                        
                        VStack
                        {
                            HStack
                            {
                                Text("Cast").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                Spacer()
                            }.padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false)
                            {
                                Divider().padding(.horizontal, 20)
                                HStack
                                {
                                    Spacer()
                                    Spacer()
                                    HStack(spacing: 20)
                                    {
                                        ForEach((viewModel.singleMovie?.actors)!)
                                        {actor in
                                            VStack()
                                            {
                                                
                                                Image("Zindre").resizable().frame(width: 100, height: 141)
                                                HStack
                                                {
                                                    Text(actor.full_name!)
                                                }.padding(.horizontal, 30)
                                                
                                            }
                                            .padding(.horizontal)
                                            
                                            Divider()
                                        }

                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                }
                                
                                Divider().padding(.horizontal, 20)
                            }
                        }.padding(.vertical, 40)
                        
                        
                        VStack(alignment: .leading, spacing: 10)
                        {
                            HStack
                            {
                                Text("Other infos").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                Spacer()
                            }.padding(.horizontal, 20)
                            
                            
                            VStack(alignment: .leading, spacing: 5)
                                {
                                    Text("Production companies: ")
                                        .bold() + Text(viewModel.singleMovie!.getCompanies())
                                    
                                    Text("Spoken languages: ")
                                        .bold() + Text(viewModel.singleMovie!.getLanguages())
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 10)
                        {
                            HStack
                            {
                                Text("Reviews").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                Spacer()
                            }.padding(.horizontal, 20)
                            
                            
                            VStack(alignment: .leading, spacing: 5)
                                {
                                    Text("Production companies: ")
                                        .bold() + Text(viewModel.singleMovie!.getCompanies())
                                    
                                    Text("Spoken languages: ")
                                        .bold() + Text(viewModel.singleMovie!.getLanguages())
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            
                        }
                        
                        
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .onAppear {
            viewModel.getMovie(movieId: movieId)
        }
    }
}

#Preview {
    MovieView(movieId: "667590309c7bec2c21dcca2c")
}
