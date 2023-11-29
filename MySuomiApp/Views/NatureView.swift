import SwiftUI
import URLImage
import CoreData


struct NatureView: View {
    @State private var naturePlaces: [Place] = []
    @State private var hasFetchedData = false
    
    
    var body: some View {
        
        // Display your nature places here
        List(naturePlaces, id: \.place_id) { place in
            NavigationLink(destination: DetailView(place: place)) {
                HStack {
                    CardView(title: place.name, imageURL: imageURL(photoReference: place.photos?.first?.photo_reference ?? "", maxWidth: 100))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            // Fetch data only if it hasn't been fetched before
            if !hasFetchedData {
                fetchAndSaveNaturePlaces()
                hasFetchedData = true
            }
        }
        
        
        .navigationTitle("Nature")
    }
    
    // Modified function to fetch and save nature places
    func fetchAndSaveNaturePlaces() {
        // Fetch existing places from Core Data
        let existingPlaces = PersistenceController.shared.fetchPlaces()
        
        // Create a set to store unique places
        var uniquePlaces: Set<Place> = Set(existingPlaces)
        
        // Create a dispatch group to wait for all fetches to complete
        let dispatchGroup = DispatchGroup()
        
        // Iterate over each type in natureTypes and fetch places
        for type in natureTypes {
            dispatchGroup.enter() // Enter the group before starting a fetch
            
            // Use the type.rawValue to fetch places for the current type
            fetchPlaces(for: [type.rawValue]) { places in
                defer {
                    dispatchGroup.leave() // Leave the group when the fetch is complete
                }
                
                if let places = places {
                    // Add the fetched places to the set
                    uniquePlaces.formUnion(places)
                } else {
                    // Handle error or display an error message
                    print("Failed to fetch nature places")
                }
            }
        }
        
        // Notify when all fetches are complete
        dispatchGroup.notify(queue: .main) {
            // Convert the set back to an array and update the state
            naturePlaces = Array(uniquePlaces)
            
            // Save the unique places to Core Data
            PersistenceController.shared.savePlaces(Array(uniquePlaces))
        }
    }
}
