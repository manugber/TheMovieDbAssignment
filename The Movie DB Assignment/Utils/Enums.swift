//
//  Enums.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 18/11/24.
//

import Foundation

enum SearchScope: String, CaseIterable {
    case movie = "Movies"
    case serie = "Series"
}

enum ImageType {
    case backdrop
    case poster
}
