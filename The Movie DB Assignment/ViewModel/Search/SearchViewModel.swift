//
//  SearchViewModel.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 14/11/24.
//

import Foundation
import SwiftUICore
import Combine

final class SearchViewModel: ObservableObject {
    
    @Published var searchedMediaList: [any MediaProtocol] = []
    @Published var suggestionList: [String] = []
    @Published var isSearching = false
    @Published var searchQuery = ""
    @Published var searchScope = SearchScope.movie
    
    private var searchPage = 1
    private var totalSearchPages = 1
    private var cancellables = Set<AnyCancellable>()
    private var networkManager = NetworkManager.shared
    private let appViewModel = AppViewModel.shared
    private let genreViewModel = GenreViewModel.shared
    
    static let shared = SearchViewModel()
    
    private init() {
        $searchQuery
            .debounce(for: 0.4, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.onSearchQueryUpdated()
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func loadSuggestions() async {
        resetSearchStatus()
        guard let url = getSearchUrl() else { return }
        do {
            if searchScope == .movie {
                let decodedData = try await networkManager.fetchData(url: url, type: MovieListInDto.self)
                decodedData.results.forEach { movie in
                    if !suggestionList.contains(where: { $0 == movie.title }) {
                        withAnimation {
                            suggestionList.append(movie.title)
                        }
                    }
                }
            } else {
                let decodedData = try await networkManager.fetchData(url: url, type: SerieListInDto.self)
                decodedData.results.forEach { serie in
                    if !suggestionList.contains(where: { $0 == serie.name }) {
                        withAnimation {
                            suggestionList.append(serie.name)
                        }
                    }
                }
            }
        } catch let appError as ApiError {
            appViewModel.currentError = appError
        } catch {
            appViewModel.currentError = ApiError.unknownError
        }
    }
    
    func searchMoreMediaIfNeeded(mediaId: Int) async {
        guard searchedMediaList.last?.id == mediaId && currentPageIsNotLastOne() else { return }
        await searchMedia(requestedPage: searchPage + 1)
    }
    
    func currentPageIsNotLastOne() -> Bool {
        return searchPage < totalSearchPages
    }
    
    func updateSearch() {
        if !searchQuery.isEmpty {
            Task {
                await resetSearchStatus()
                await searchMedia(requestedPage: 1)
            }
        }
    }
    
    func onSearchScopeUpdated() {
        if !searchQuery.isEmpty {
            Task {
                await loadSuggestions()
            }
        }
    }
    
    private func onSearchQueryUpdated() {
        if searchQuery.isEmpty {
            Task {
                await resetSearchStatus()
            }
        } else {
            guard searchedMediaList.isEmpty else { return }
            Task {
                await loadSuggestions()
            }
        }
    }
    
    @MainActor
    private func resetSearchStatus() {
        searchPage = 1
        totalSearchPages = 1
        searchedMediaList = []
        suggestionList = []
    }
    
    @MainActor
    private func searchMedia(requestedPage: Int) async {
        guard let url = getSearchUrl(requestedPage: requestedPage) else { return }
        do {
            if searchScope == .movie {
                let decodedData = try await networkManager.fetchData(url: url, type: MovieListInDto.self)
                let filteredMovies = decodedData.results
                    .filter({ movie in !searchedMediaList.contains(where: { $0.id == movie.id }) })
                    .map { movie in MovieEntity(movie: movie, genres: genreViewModel.getGenres(ids: movie.genreIDs)) }
                withAnimation {
                    searchedMediaList.append(contentsOf: filteredMovies)
                }
                searchPage = decodedData.page
                totalSearchPages = decodedData.totalPages
            } else {
                let decodedData = try await networkManager.fetchData(url: url, type: SerieListInDto.self)
                let filteredSeries = decodedData.results
                    .filter({ serie in !searchedMediaList.contains(where: { $0.id == serie.id }) })
                    .map { serie in SerieEntity(serie: serie, genres: genreViewModel.getGenres(ids: serie.genreIDs)) }
                withAnimation {
                    searchedMediaList.append(contentsOf: filteredSeries)
                }
                searchPage = decodedData.page
                totalSearchPages = decodedData.totalPages
            }
        } catch let appError as ApiError {
            appViewModel.currentError = appError
        } catch {
            appViewModel.currentError = ApiError.unknownError
        }
    }
    
    private func getSearchUrl(requestedPage: Int? = nil) -> URL? {
        let scopePath = searchScope == .movie ? ApiConfig.movie : ApiConfig.serie
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: ApiConfig.query, value: searchQuery)
        ]
        if let requestedPage = requestedPage {
            queryItems.append(URLQueryItem(name: ApiConfig.page, value: String(requestedPage)))
        }
        let stringUrl = ApiConfig.baseUrl + ApiConfig.search + scopePath
        guard let url = URL(string: stringUrl),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            appViewModel.currentError = ApiError.urlError("URL \(stringUrl) is invalid")
            return nil
        }
        
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        guard let componentsUrl = components.url else {
            appViewModel.currentError = ApiError.urlError("Error in query items")
            return nil
        }
        return componentsUrl
    }
}
