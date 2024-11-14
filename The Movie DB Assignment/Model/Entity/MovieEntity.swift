//
//  MovieEntity.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 13/11/24.
//

import Foundation
import SwiftData

@Model
class MovieEntity: Identifiable, MediaProtocol {
    var adult: Bool
    var backdropPath: String?
    @Relationship var genres: [GenreEntity]
    var id: Int
    var originalLanguage: String
    var originalTitle: String
    var overview: String
    var popularity: Double
    var posterPath: String?
    var releaseDate: String
    var title: String
    var video: Bool
    var voteAverage: Double
    var voteCount: Int
    
    init(movie: MovieInDto, genres: [GenreEntity]) {
        self.adult = movie.adult
        self.backdropPath = movie.backdropPath
        self.genres = genres
        self.id = movie.id
        self.originalLanguage = movie.originalLanguage
        self.originalTitle = movie.originalTitle
        self.overview = movie.overview
        self.popularity = movie.popularity
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.title = movie.title
        self.video = movie.video
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
    }
}

extension MovieEntity {
    func isFavourite(context: ModelContext) -> Bool {
        let movieId = self.id
        let request = FetchDescriptor<MovieEntity>(predicate: #Predicate { $0.id == movieId })
        let results = try? context.fetch(request)
        return !(results?.isEmpty ?? true)
    }

    func addFavourite(context: ModelContext) {
        context.insert(self)
        try? context.save()
    }

    func removeFavourite(context: ModelContext) {
        let movieId = self.id
        let request = FetchDescriptor<MovieEntity>(predicate: #Predicate { $0.id == movieId })
        if let results = try? context.fetch(request), let favorite = results.first {
            context.delete(favorite)
            try? context.save()
        }
    }
}
