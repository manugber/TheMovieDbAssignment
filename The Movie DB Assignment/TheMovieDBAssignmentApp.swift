//
//  The_MovieDBAssignmentApp.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 12/11/24.
//

import SwiftUI
import SwiftData

@main
struct TheMovieDBAssignmentApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppViewModel.shared)
                .environmentObject(TrendingViewModel.shared)
                .environmentObject(SearchViewModel.shared)
            
        }
        .modelContainer(for: [MovieEntity.self, SerieEntity.self, GenreEntity.self])
    }
}
