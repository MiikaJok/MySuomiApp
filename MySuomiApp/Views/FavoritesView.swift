import SwiftUI
import CoreData

struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var languageSettings: LanguageSettings

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

                        NavigationLink(
                            destination: DetailView(place: Place(name: name, place_id: "", rating: nil, types: [], vicinity: "", opening_hours: nil, photos: [Photo(photo_reference: imageUrlString, width: 0, height: 0)]))
                                .environmentObject(languageSettings),

                            label: {
                                HStack {
                                    CardView(title: name, imageURL: imageUrl, onDelete: {
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

    private func removeLikeFromCoreData(_ place: Like) {
        withAnimation {
            viewContext.delete(place)
            do {
                try viewContext.save()
            } catch {
                print("Error removing liked item from CoreData: \(error)")
            }
        }
    }
}
