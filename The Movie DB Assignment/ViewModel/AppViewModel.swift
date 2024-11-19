//
//  AppViewModel.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 12/11/24.
//

import Foundation
import SwiftUI

final class AppViewModel: ObservableObject {
    
    @Published var currentError: ApiError?
    
    private var posterSizeList: [CGFloat] = []
    private var backdropSizeList: [CGFloat] = []
    private var imageUrlBasePath: String?
    private var networkManager = NetworkManager.shared
    private lazy var genreViewModel = GenreViewModel.shared
    private lazy var trendingViewModel = TrendingViewModel.shared
    
    static let shared = AppViewModel()
    
    private init() {}
    
    func loadInitialContent() async {
        await loadConfiguration()
        await genreViewModel.loadGenres(genresFor: ApiConfig.movie)
        await genreViewModel.loadGenres(genresFor: ApiConfig.serie)
        await trendingViewModel.loadTrendingMovieList(requestedPage: 1)
    }
    
    func getImageUrl(filePath: String, desiredWidth: CGFloat, imageType: ImageType) -> URL? {
        guard let imageUrlBasePath = imageUrlBasePath,
              let calculatedFileSize = calculateWidth(desiredWidth: desiredWidth, imageType: imageType) else { return nil }
        return URL(string: "\(imageUrlBasePath)\(calculatedFileSize)\(filePath)")
    }
    
    @MainActor
    private func loadConfiguration() async {
        let stringUrl = ApiConfig.baseUrl + ApiConfig.configuration
        guard let url = URL(string: stringUrl) else {
            currentError = ApiError.urlError("URL \(stringUrl) is invalid")
            return
        }
        
        do {
            let decodedData = try await networkManager.fetchData(url: url, type: ConfigurationInDto.self)
            imageUrlBasePath = decodedData.images.secureBaseURL
            posterSizeList = decodedData.images.posterSizes.convertToCGFloat()
            backdropSizeList = decodedData.images.backdropSizes.convertToCGFloat()
        } catch let appError as ApiError {
            currentError = appError
        } catch {
            currentError = ApiError.unknownError
        }
    }
    
    private func calculateWidth(desiredWidth: CGFloat, imageType: ImageType) -> String? {
        let sizeList: [CGFloat]
        if imageType == .poster {
            sizeList = posterSizeList
        } else {
            sizeList = backdropSizeList
        }
        guard let maxWidth = sizeList.last else { return nil }
        if desiredWidth > maxWidth {
            return "original"
        }
        guard let selectedSize = sizeList.first(where: { $0 >= desiredWidth }) else { return nil }
        return "w\(Int(selectedSize))"
    }
}
