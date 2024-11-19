//
//  MediaDetailsView.swift
//  The Movie DB Assignment
//
//  Created by Manuel Gonzalez Bernaldez on 12/11/24.
//

import SwiftUI

struct MediaDetailsView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isFavourite = false
    let media: any MediaProtocol
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                getMediaImage(geometry: geometry, imageType: .backdrop)
                if isIphoneAndLandscape {
                    getLandscapeScrollView(geometry: geometry)
                } else {
                    getPortraitScrollView(geometry: geometry)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension MediaDetailsView {
    var isIphoneAndLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var isIpad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var titleAndMainInfo: some View {
        VStack(spacing: 16) {
            Text(media.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top)
            genresAndVote
                .padding(.horizontal)
            Text("Release Date: \(media.releaseDate)")
                .font(.footnote)
                .foregroundStyle(.gray)
        }
    }
    
    var genresAndVote: some View {
        HStack {
            if !media.genres.isEmpty {
                Text(GenreEntity.getGenreNames(genres: media.genres))
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text("\(String(format: "%.1f", media.voteAverage))/10")
                .font(.subheadline)
                .foregroundStyle(.yellow)
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("Votes: \(media.voteCount)")
                .font(.footnote)
                .foregroundStyle(.gray)
        }
    }
    
    var overview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overview")
                .font(.headline)
                .padding(.bottom, 4)

            Text(media.overview)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding()
    }
    
    var favouriteButton: some View {
        Button(action: {
            withAnimation {
                isFavourite.toggle()
            }
            media.toggleFavourite(context: context)
        }, label: {
            HStack {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                Text(isFavourite ? "Remove from favourites" : "Add to favourites")
            }
        })
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .onAppear {
            isFavourite = media.isFavourite(context: context)
        }
    }
    
    var gradient: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: .clear, location: 0.0),
                Gradient.Stop(color: Color(UIColor.systemBackground), location: isIphoneAndLandscape ? 0.40 : 0.25)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(.all)
    }
    
    func getMediaImage(geometry: GeometryProxy, imageType: ImageType) -> some View {
        Group {
            let width = calculateImageWidth(geometry: geometry, isBackdrop: imageType == .backdrop)
            if let posterPath = imageType == .poster ? media.posterPath : media.backdropPath,
               let url = appViewModel.getImageUrl(filePath: posterPath, desiredWidth: width, imageType: imageType) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: imageType == .backdrop ? .fill : .fit)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: width, alignment: .top)
                .frame(maxHeight: imageType == .backdrop ? calculateBackdropMaxHeight(geometry: geometry) : nil)
                .clipped()
            } else {
                Color.gray.opacity(0.3)
            }
        }
    }
    
    func getLandscapeScrollView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack {
                Spacer()
                    .frame(height: geometry.size.height * 0.45)
                HStack(alignment: .top) {
                    getMediaImage(geometry: geometry, imageType: .poster)
                        .shadow(radius: 10)
                        .cornerRadius(10)
                    VStack {
                        titleAndMainInfo
                        overview
                        Spacer()
                        favouriteButton
                    }
                }
            }
            .padding(8)
            .frame(minHeight: geometry.size.height * 1.425)
            .background {
                gradient
            }
        }
    }
    
    func getPortraitScrollView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack {
                Spacer()
                    .frame(height: geometry.size.height * 0.20)
                getMediaImage(geometry: geometry, imageType: .poster)
                    .shadow(radius: 10)
                    .cornerRadius(10)
                titleAndMainInfo
                overview
                Spacer()
                favouriteButton
            }
            .padding(8)
            .frame(minHeight: geometry.size.height * 1.175)
            .background {
                gradient
            }
        }
    }
    
    func calculateImageWidth(geometry: GeometryProxy, isBackdrop: Bool) -> Double {
        let parentWidth = geometry.size.width
        if isBackdrop {
            return parentWidth
        }
        if isIphoneAndLandscape {
            return parentWidth * 0.2
        }
        if isIpad {
            return parentWidth * 0.3
        }
        return parentWidth * 0.4
    }
    
    func calculateBackdropMaxHeight(geometry: GeometryProxy) -> Double {
        let parentHeight = geometry.size.height
        if isIphoneAndLandscape {
            return parentHeight * 0.6
        }
        if isIpad {
            return parentHeight * 0.4
        }
        return parentHeight * 0.3
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
    
    MediaDetailsView(media: MovieEntity(movie: mockMovieInDto, genres: mockGenres))
}
