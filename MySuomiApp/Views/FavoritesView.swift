import SwiftUI
import CoreData

//shows the "liked" places in a listview
struct FavoritesView: View {
    // Inject the managedObjectContext to interact with Core Data
    @Environment(\.managedObjectContext) private var viewContext
    
    // Access the LanguageSettings environment object for language preferences
    @EnvironmentObject var languageSettings: LanguageSettings
    
    // Fetch request to retrieve all liked items from Core Data
    @FetchRequest(
        entity: Like.entity(),
        sortDescriptors: []
    ) var fetchedLikes: FetchedResults<Like>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(fetchedLikes, id: \.self) { like in
                    if let name = like.name,
                       let imageUrlString = like.image,
                       let imageUrl = URL(string: imageUrlString) {
                        HStack {
                            CardView(title: name, imageURL: imageUrl)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
    
    // Function to delete a liked item from Core Data
    private func deleteLike(_ place: Like) {
        withAnimation {
            viewContext.delete(place)
            do {
                // Save the changes to Core Data
                try viewContext.save()
            } catch {
                // Handle errors in case of failure
                print("Error deleting place: \(error)")
            }
        }
    }
}
