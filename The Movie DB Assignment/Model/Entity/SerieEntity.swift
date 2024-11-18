//
//  SerieEntity.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 13/11/24.
//

import Foundation
import SwiftData

@Model
class SerieEntity: MediaProtocol {
    var adult: Bool
    var backdropPath: String?
    @Relationship var genres: [GenreEntity]
    var id: Int
    var originalLanguage: String
    var originalName: String
    var overview: String
    var popularity: Double
    var posterPath: String?
    var releaseDate: String
    var title: String
    var voteAverage: Double
    var voteCount: Int
    
    init(serie: SerieInDto, genres: [GenreEntity]) {
        self.adult = serie.adult
        self.backdropPath = serie.backdropPath
        self.genres = genres
        self.id = serie.id
        self.originalLanguage = serie.originalLanguage
        self.originalName = serie.originalName
        self.overview = serie.overview
        self.popularity = serie.popularity
        self.posterPath = serie.posterPath
        self.releaseDate = serie.firstAirDate
        self.title = serie.name
        self.voteAverage = serie.voteAverage
        self.voteCount = serie.voteCount
    }
}

extension SerieEntity {
    func isFavourite(context: ModelContext) -> Bool {
        let serieId = self.id
        let request = FetchDescriptor<SerieEntity>(predicate: #Predicate { $0.id == serieId })
        let results = try? context.fetch(request)
        return !(results?.isEmpty ?? true)
    }
    
    func addFavourite(context: ModelContext) {
        context.insert(self)
        try? context.save()
    }

    func removeFavourite(context: ModelContext) {
        let serieId = self.id
        let request = FetchDescriptor<SerieEntity>(predicate: #Predicate { $0.id == serieId })
        if let results = try? context.fetch(request), let favorite = results.first {
            context.delete(favorite)
            try? context.save()
        }
    }
}
