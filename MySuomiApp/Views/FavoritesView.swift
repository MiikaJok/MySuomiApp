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
                ForEach(fetchedLikes, id: \.self) { like in
                    if let name = like.name,
                       let imageUrlString = like.image,
                       let imageUrl = URL(string: imageUrlString) {
                        HStack {
                            // Use CardView with heart icon from CardView
                            CardView(title: name, imageURL: imageUrl)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
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
