import SwiftUI
import CoreData

// FavoritesView: A SwiftUI view displaying a list of user's favorite places.
struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var languageSettings: LanguageSettings

    // Fetch all liked items from CoreData using Core Data's @FetchRequest property wrapper
    @FetchRequest(
        entity: Like.entity(),
        sortDescriptors: []
    ) var fetchedLikes: FetchedResults<Like>

    var body: some View {
        NavigationView {
            // Display a list of liked items
            List {
                // Iterate through fetchedLikes to display each liked item
                ForEach(fetchedLikes, id: \.self) { like in
                    // Unwrap necessary information from the Like entity
                    if let name = like.name,
                       let imageUrlString = like.image,
                       let imageUrl = URL(string: imageUrlString) {

                        // Use NavigationLink to navigate to a detailed view when a liked item is tapped
                        NavigationLink(
                            destination: DetailView(place: Place(name: name, place_id: "", rating: nil, types: [], vicinity: "", opening_hours: nil, photos: [Photo(photo_reference: imageUrlString, width: 0, height: 0)]))
                                .environmentObject(languageSettings),

                            label: {
                                // Display a CardView for each liked item, allowing deletion
                                HStack {
                                    CardView(title: name, imageURL: imageUrl, onDelete: {
                                        // Call removeLikeFromCoreData to delete the liked item
                                        removeLikeFromCoreData(like)
                                    })
                                    .padding(.vertical, 8)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
    // Function to remove a liked item from CoreData with animation
    private func removeLikeFromCoreData(_ place: Like) {
        withAnimation {
            // Delete the liked item from the managed object context
            viewContext.delete(place)
            do {
                // Save the changes to the managed object context
                try viewContext.save()
            } catch {
                // Handle errors during saving
                print("Error removing liked item from CoreData: \(error)")
            }
        }
    }
}
