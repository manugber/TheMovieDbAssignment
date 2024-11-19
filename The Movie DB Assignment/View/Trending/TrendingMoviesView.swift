//
//  TrendingMoviesView.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 13/11/24.
//

import SwiftUI
import SwiftData

struct TrendingMoviesView: View {
    
    @EnvironmentObject var trendingViewModel: TrendingViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @Query var favouriteMovies: [MovieEntity]
    
    var body: some View {
        if searchViewModel.isSearching {
            SearchView()
        } else {
            trendingList
        }
    }
}

extension TrendingMoviesView {
    var trendingList: some View {
        GeometryReader { geometry in
            List {
                ForEach(trendingViewModel.favouritesOnly ? favouriteMovies : trendingViewModel.movies, id: \.id) { media in
                    NavigationLink(destination: MediaDetailsView(media: media)) {
                        MediaRowView(media: media, geometry: geometry)
                            .task {
                                await trendingViewModel.loadMoreTrendingMovieListIfNeeded(mediaId: media.id)
                            }
                    }
                }
                if trendingViewModel.currentPageIsNotLastOneAndNotFavouritesOnly() {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .id(UUID())
                }
            }
            .navigationTitle(trendingViewModel.favouritesOnly ? "Favourites" : "Trending movies")
            .toolbar {
                toolbar
            }
            .listStyle(.inset)
            .padding()
        }
    }
    
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                withAnimation {
                    trendingViewModel.favouritesOnly.toggle()
                }
            }, label: {
                Image(systemName: trendingViewModel.favouritesOnly ? "heart.fill" : "heart")
            })
        }
    }
}

#Preview {
    TrendingMoviesView()
}
