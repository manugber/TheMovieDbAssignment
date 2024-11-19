//
//  TrendingViewModel.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 14/11/24.
//

import Foundation
import SwiftUICore

final class TrendingViewModel: ObservableObject {
    
    @Published var movies: [MovieEntity] = []
    @Published var favouritesOnly = false
    
    private var page = 1
    private var totalPages = 1
    private var networkManager = NetworkManager.shared
    private let appViewModel = AppViewModel.shared
    private let genreViewModel = GenreViewModel.shared
    
    static let shared = TrendingViewModel()
    
    private init() {}
    
    @MainActor
    func loadTrendingMovieList(requestedPage: Int) async {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: ApiConfig.page, value: String(requestedPage))
        ]
        let stringUrl = ApiConfig.baseUrl + ApiConfig.discover + ApiConfig.movie
        guard let url = URL(string: stringUrl),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            appViewModel.currentError = ApiError.urlError("URL \(stringUrl) is invalid")
            return
        }
        
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        guard let componentsUrl = components.url else {
            appViewModel.currentError = ApiError.urlError("Error in query items")
            return
        }
        
        do {
            let decodedData = try await networkManager.fetchData(url: componentsUrl, type: MovieListInDto.self)
            let filteredMovies = decodedData.results
                .filter({ movie in !movies.contains(where: { $0.id == movie.id }) })
                .map { movie in MovieEntity(movie: movie, genres: genreViewModel.getGenres(ids: movie.genreIDs)) }
            withAnimation {
                movies.append(contentsOf: filteredMovies)
            }
            page = decodedData.page
            totalPages = decodedData.totalPages
        } catch let appError as ApiError {
            appViewModel.currentError = appError
        } catch {
            appViewModel.currentError = ApiError.unknownError
        }
    }
    
    func loadMoreTrendingMovieListIfNeeded(mediaId: Int) async {
        guard movies.last?.id == mediaId && currentPageIsNotLastOneAndNotFavouritesOnly() else { return }
        await loadTrendingMovieList(requestedPage: page + 1)
    }
    
    func currentPageIsNotLastOneAndNotFavouritesOnly() -> Bool {
        return !favouritesOnly && page < totalPages
    }
}
