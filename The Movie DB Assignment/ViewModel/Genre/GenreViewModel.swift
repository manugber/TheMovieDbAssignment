//
//  GenreViewModel.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 14/11/24.
//

import Foundation

final class GenreViewModel {
    
    var genres: [GenreEntity] = []
    private let appViewModel = AppViewModel.shared
    
    private var networkManager = NetworkManager.shared
    
    static let shared = GenreViewModel()
    
    private init() {}
    
    @MainActor
    func loadGenres(genresFor: String) async {
        let stringUrl = ApiConfig.baseUrl + ApiConfig.genre + genresFor + ApiConfig.list
        guard let url = URL(string: stringUrl) else {
            appViewModel.currentError = ApiError.urlError("URL \(stringUrl) is invalid")
            return
        }
        
        do {
            let decodedData = try await networkManager.fetchData(url: url, type: GenreListInDto.self)
            let filteredGenres = decodedData.genres
                .filter({ genre in !genres.contains(where: { $0.id == genre.id }) })
                .map { genre in GenreEntity(genre: genre) }
            genres.append(contentsOf: filteredGenres)
        } catch let appError as ApiError {
            appViewModel.currentError = appError
        } catch {
            appViewModel.currentError = ApiError.unknownError
        }
    }
        
    func getGenres(ids: [Int]) -> [GenreEntity] {
        return ids.compactMap { id in
            genres.first(where: { $0.id == id })
        }
    }
}
