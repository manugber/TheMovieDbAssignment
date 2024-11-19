//
//  Constants.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 12/11/24.
//

import Foundation

enum ApiConfig {
    static let page = "page"
    static let query = "query"
    static let configuration = "/configuration"
    static let discover = "/discover"
    static let movie = "/movie"
    static let genre = "/genre"
    static let list = "/list"
    static let search = "/search"
    static let serie = "/tv"
    
    private static let baseUrlKey = "API_BASE_URL"
    private static let bearerTokenKey = "BEARER_TOKEN"
    
    private static let infoDictionary: [String: Any] = {
        guard let dictionary = Bundle.main.infoDictionary else {
            fatalError(".plist file not found")
        }
        return dictionary
    }()
    
    static let baseUrl: String = {
        guard let baseUrl = ApiConfig.infoDictionary[ApiConfig.baseUrlKey] as? String else {
            fatalError("\(ApiConfig.baseUrlKey) not set in .plist")
        }
        return baseUrl
    }()
    
    static let accessToken: String = {
        guard let accessToken = ApiConfig.infoDictionary[ApiConfig.bearerTokenKey] as? String else {
            fatalError("\(ApiConfig.bearerTokenKey) not set in .plist")
        }
        return accessToken
    }()
}
