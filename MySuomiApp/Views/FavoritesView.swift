//
//  FavoritesView.swift
//  MySuomiApp
//

import URLImage
import SwiftUI
import CoreData

struct FavoritesView: View {
    // Fetch liked places from Core Data
    let likedPlaces = PersistenceController.shared.fetchPlaces()
    

    var body: some View {
        List(likedPlaces, id: \.place_id) { place in
            NavigationLink(destination: DetailView(place: place)) {
                CardView(title: place.name ?? "Unknown Place", imageURL: imageURL(photoReference: place.photos?.first?.photo_reference ?? "", maxWidth: 100))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("Favorites")
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(LanguageSettings())
    }
}
