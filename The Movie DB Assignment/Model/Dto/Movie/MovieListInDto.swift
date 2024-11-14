//
//  DiscoverMovieInDto.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 12/11/24.
//

import Foundation

struct MovieListInDto: Codable {
    let page: Int
    let results: [MovieInDto]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
