//
//  GenreEntity.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 13/11/24.
//

import Foundation
import SwiftData

@Model
class GenreEntity: Identifiable {
    var id: Int
    var name: String
    
    init(genre: GenreInDto) {
        self.id = genre.id
        self.name = genre.name
    }
}

extension GenreEntity {
    static func getGenreNames(genres: [GenreEntity]) -> String {
        let names = genres.map { $0.name }
        return names.sorted().joined(separator: ", ")
    }
}
