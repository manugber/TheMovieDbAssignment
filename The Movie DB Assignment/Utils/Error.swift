//
//  Error.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 12/11/24.
//

import Foundation

enum ApiError: Error, LocalizedError, Identifiable {
    case networkError(String)
    case decodingError(String)
    case urlError(String)
    case unknownError
    
    var id: String {
        localizedDescription
    }
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError(let message):
            return "Decoding Error: \(message)"
        case .urlError(let message):
            return "URL Error: \(message)"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
