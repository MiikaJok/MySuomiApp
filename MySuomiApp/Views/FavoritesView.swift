//
//  FavoritesView.swift
//  MySuomiApp
//
import SwiftUI
import CoreData


struct FavoritesView: View {
    // Inject the managedObjectContext
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch request to get all likes
    @FetchRequest(
        entity: Like.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Like.name, ascending: true)
        ]
    ) var likedPlaces: FetchedResults<Like>
    
    var body: some View {
        NavigationView {
            List {
                let uniqueLikedPlaces = Array(Set(likedPlaces))
                
                ForEach(uniqueLikedPlaces, id: \.self) { place in
                    if let name = place.name,
                       let imageUrlString = place.image,
                       let imageUrl = URL(string: imageUrlString) {
                        CardView(title: name, imageURL: imageUrl)
                            .contextMenu {
                                Button(action: {
                                    deleteLike(place)
                                }) {
                                    Text("Remove from Favorites")
                                    Image(systemName: "heart.fill")
                                }
                            }
                    }
                }
            }
            .navigationBarTitle("Favorites")
        }
    }
    
    private func deleteLike(_ place: Like) {
        withAnimation {
            viewContext.delete(place)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting place: \(error)")
            }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
