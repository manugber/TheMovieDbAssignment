//
//  MediaProtocol.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 13/11/24.
//

import Foundation
import SwiftData

protocol MediaProtocol: Identifiable, Hashable {
    var adult: Bool { get set }
    var backdropPath: String? { get set }
    var genres: [GenreEntity] { get set }
    var id: Int { get set }
    var originalLanguage: String { get set }
    var overview: String { get set }
    var popularity: Double { get set }
    var posterPath: String? { get set }
    var releaseDate: String { get set }
    var title: String { get set }
    var voteAverage: Double { get set }
    var voteCount: Int { get set }
    
    func toggleFavourite(context: ModelContext)
    func isFavourite(context: ModelContext) -> Bool
    func addFavourite(context: ModelContext)
    func removeFavourite(context: ModelContext)
}

extension MediaProtocol {
    func toggleFavourite(context: ModelContext) {
        if isFavourite(context: context) {
            removeFavourite(context: context)
        } else {
            addFavourite(context: context)
        }
    }
}
