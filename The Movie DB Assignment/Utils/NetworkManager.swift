//
//  NetworkManager.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 18/11/24.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchData<T: Codable>(url: URL, type: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": ApiConfig.accessToken]
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw ApiError.networkError("Status code from server: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            throw ApiError.decodingError(error.localizedDescription)
        } catch {
            throw ApiError.networkError(error.localizedDescription)
        }
    }
}
