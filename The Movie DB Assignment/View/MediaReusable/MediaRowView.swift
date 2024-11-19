//
//  MediaRowView.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 12/11/24.
//

import SwiftUI

struct MediaRowView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var isFavourite = false
    let media: any MediaProtocol
    let geometry: GeometryProxy
    let posterAspectRatio: Double = 3 / 2

    var body: some View {
        HStack {
            image
            information
        }
        .padding(.vertical, 8)
    }
}

extension MediaRowView {
    var image: some View {
        Group {
            if let posterPath = media.posterPath,
               let url = appViewModel.getImageUrl(filePath: posterPath, desiredWidth: imageWidth, imageType: .poster) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(width: imageWidth, height: imageWidth * posterAspectRatio)
                }
                .frame(width: imageWidth)
                .cornerRadius(8)
            }
        }
    }
    
    var information: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(media.title)
                    .font(.headline)
                Spacer()
                Button(action: {
                }, label: {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .foregroundColor(isFavourite ? .red : .gray)
                })
                .onAppear {
                    isFavourite = media.isFavourite(context: context)
                }
                .onTapGesture {
                    withAnimation {
                        isFavourite.toggle()
                    }
                    media.toggleFavourite(context: context)
                }
            }
            Text(media.overview)
                .lineLimit(5)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    var imageWidth: Double {
        geometry.size.width * (verticalSizeClass == .compact ? 0.1 : 0.33)
    }
}

#Preview {
    let mockGenres: [GenreEntity] = [
        GenreEntity(genre: GenreInDto(id: 1, name: "Action")),
        GenreEntity(genre: GenreInDto(id: 2, name: "Adventure"))
    ]

    let mockMovieInDto = MovieInDto(
        adult: false,
        backdropPath: "/mockBackdrop.jpg",
        genreIDs: [1, 2],
        id: 1,
        originalLanguage: "en",
        originalTitle: "Original Title",
        overview: "Overview",
        popularity: 20,
        posterPath: "/mockPoster.jpg",
        releaseDate: "2024-01-01",
        title: "Title",
        video: false,
        voteAverage: 7.8,
        voteCount: 100
    )

    GeometryReader { geometry in
        MediaRowView(media: MovieEntity(movie: mockMovieInDto, genres: mockGenres),
                     geometry: geometry)
    }
}
