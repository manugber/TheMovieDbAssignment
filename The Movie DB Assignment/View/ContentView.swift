//
//  ContentView.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 12/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            TrendingMoviesView()
                .searchable(text: $searchViewModel.searchQuery,
                            isPresented: $searchViewModel.isSearching,
                            prompt: "Search movies or series")
                .searchScopes($searchViewModel.searchScope) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue)
                    }
                }
                .searchSuggestions {
                    ForEach(searchViewModel.suggestionList, id: \.self) { suggestion in
                        Text(suggestion)
                            .searchCompletion(suggestion)
                    }
                }
                .onSubmit(of: .search) {
                    searchViewModel.updateSearch()
                }
                .onChange(of: searchViewModel.searchQuery) {
                    searchViewModel.searchedMediaList = []
                }
                .onChange(of: searchViewModel.searchScope) {
                    searchViewModel.onSearchScopeUpdated()
                }
        } detail: {
            
        }
        .navigationSplitViewStyle(.balanced)
        .task {
            await appViewModel.loadInitialContent()
        }
        .alert(item: $appViewModel.currentError) { error in
            Alert(title: Text("Error"),
                  message: Text(error.localizedDescription),
                  dismissButton: .default(Text("OK")) {
                    appViewModel.currentError = nil
                }
            )
        }
    }
}

#Preview {
    ContentView()
}