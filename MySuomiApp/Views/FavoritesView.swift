//
//  FavoritesView.swift
//  MySuomiApp
//
import SwiftUI
import CoreData


struct FavoritesView: View {
  // Inject the managedObjectContext
  @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var languageSettings: LanguageSettings


  // Fetch request to get all likes
  @FetchRequest(
    entity: Like.entity(),
    sortDescriptors: []
  ) var fetchedLikes: FetchedResults<Like>

  var body: some View {
    NavigationView {
      List {
        //let uniqueLikedPlaces = Array(fetchedLikes)

        ForEach(fetchedLikes, id: \.self) { like in
          if let name = like.name,
             let imageUrlString = like.image,
             let imageUrl = URL(string: imageUrlString) {
            CardView(title: name, imageURL: imageUrl)
              .contextMenu {
                Button(action: {
                  deleteLike(like)
                }) {
                    Text(LocalizedStringKey("Remove from Favorites"))
                  Image(systemName: "heart.fill")
                }
              }
          }
        }

      }
      .navigationBarTitle(LocalizedStringKey("Favorites"))
    }
  }

  private func deleteLike(_ place: Like) {
    withAnimation {
      viewContext.delete(place)
      do {
        try viewContext.save()
      } catch {
        print("Error deleting place: (error)")
      }
    }
  }
}
