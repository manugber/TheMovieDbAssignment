//
//  SerieListInDto.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 13/11/24.
//

import Foundation

struct SerieListInDto: Codable {
    let page: Int
    let results: [SerieInDto]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
