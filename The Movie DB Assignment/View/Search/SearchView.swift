//
//  SearchView.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 13/11/24.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var searchViewModel: SearchViewModel
    
    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(searchViewModel.searchedMediaList, id: \.id) { media in
                    NavigationLink(destination: MediaDetailsView(media: media)) {
                        MediaRowView(media: media, geometry: geometry)
                            .task {
                                await searchViewModel.searchMoreMediaIfNeeded(mediaId: media.id)
                            }
                    }
                }
                if searchViewModel.currentPageIsNotLastOne() {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .id(UUID())
                }
            }
            .navigationTitle("Search")
            .listStyle(.inset)
            .padding()
        }
    }
}

#Preview {
    SearchView()
}
