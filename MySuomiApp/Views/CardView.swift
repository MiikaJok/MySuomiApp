import SwiftUI
import CoreData

struct CardView: View {
    let title: String
    let imageURL: URL
    @State private var isFavorite = false
    
    var onDelete: (() -> Void)? // Add a closure for the delete action

    
    // Inject the managedObjectContext
    @Environment(\.managedObjectContext) var viewContext
    
    // Check if the current item is liked when the view appears
    func checkLike() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Like")
        request.predicate = NSPredicate(format: "name == %@ AND image == %@", title, imageURL.absoluteString)
        
        do {
            if let result = try viewContext.fetch(request) as? [NSManagedObject], !result.isEmpty {
                // If the result is not empty, the item is liked
                isFavorite = true
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    var body: some View {
        HStack {
            Button(action: {
                // Toggle the favorite state
                isFavorite.toggle()
                if isFavorite {
                    // Save to CoreData when liked
                    saveLikeToCoreData()
                } else {
                    // Remove from CoreData when unliked
                    removeLikeFromCoreData()
                }
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .font(.system(size: 20))
                    .padding(.top, 8)
                    .padding(.leading, 8)
                    .imageScale(.large)
            }
                        
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .clipped()
            } placeholder: {
                ProgressView()
            }
            
            VStack(alignment: .leading) {
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            
            Spacer()
        }
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, -8)
        .padding(.vertical, 8)
        .onAppear {
            checkLike()
        }
    }
    
    // Function to save liked item to CoreData
    private func saveLikeToCoreData() {
        let newLikedItem = Like(context: viewContext)
        newLikedItem.name = title
        newLikedItem.image = imageURL.absoluteString
        
        // Save the new liked item to CoreData
        PersistenceController.shared.save()
    }
    
    // Function to remove liked item from CoreData
    private func removeLikeFromCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Like")
        request.predicate = NSPredicate(format: "name == %@ AND image == %@", title, imageURL.absoluteString)
        
        do {
            if let result = try viewContext.fetch(request) as? [NSManagedObject] {
                // Remove the liked item from CoreData
                for object in result {
                    viewContext.delete(object)
                }
                try viewContext.save()
            }
        } catch {
            print("Error removing liked item from CoreData: \(error)")
        }
        
    }
}

// Helper function to construct the image URL using the photo reference and maxWidth
func imageURL(photoReference: String, maxWidth: Int) -> URL {
    let apiKey = APIKeys.googlePlacesAPIKey
    let baseURL = "https://maps.googleapis.com/maps/api/place/photo"
    let urlString = "\(baseURL)?maxwidth=\(maxWidth)&photoreference=\(photoReference)&key=\(apiKey)"
    return URL(string: urlString)!
}

