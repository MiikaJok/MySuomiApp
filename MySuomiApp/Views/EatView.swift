import SwiftUI
import CoreData
import URLImage

struct EatView: View {
    @State private var restaurantPlaces: [Place] = []
    @State private var likedPlaces: [Place] = [] // New state variable to store liked places
    @State private var hasFetchedData = false
    
    var body: some View {
        List(restaurantPlaces, id: \.place_id) { place in
            NavigationLink(destination: EatDetailView(place: place)) {
                HStack {
                    // Pass isFavorite as a binding to CardView
                    CardView(title: place.name, imageURL: imageURL(photoReference: place.photos?.first?.photo_reference ?? "", maxWidth: 100))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            // Fetch data only if it hasn't been fetched before
            if !hasFetchedData {
                fetchAndSaveRestaurantPlaces() // Use the modified function
                
                hasFetchedData = true
            }
        }
        .navigationTitle("Restaurants")
    }
    
    // Modified function to fetch and save restaurant places
    func fetchAndSaveRestaurantPlaces() {
        // Fetch existing places from Core Data
        let existingPlaces = PersistenceController.shared.fetchPlaces()
        
        // Create a set to store unique places
        var uniquePlaces: Set<Place> = Set(existingPlaces)
        
        // Create a dispatch group to wait for all fetches to complete
        let dispatchGroup = DispatchGroup()
        
        // Iterate over each type in restaurantTypes and fetch places
        for type in restaurantTypes {
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
                    print("Failed to fetch restaurant places")
                }
            }
        }
        
        // Notify when all fetches are complete
        dispatchGroup.notify(queue: .main) {
            // Convert the set back to an array and update the state
            restaurantPlaces = Array(uniquePlaces)
            
            // Save the unique places to Core Data
            PersistenceController.shared.savePlaces(Array(uniquePlaces))
        }
    }
}

struct EatDetailView: View {
    let place: Place
    
    var body: some View {
        Form {
            Section(header: Text("Details for \(place.name)").font(.title2)) {
                VStack(alignment: .leading, spacing: 10) {
                    if let rating = place.rating {
                        Text("Rating: \(rating, specifier: "%.1f")")
                            .font(.headline)
                    } else {
                        Text("Rating: N/A")
                            .font(.headline)
                    }
                    Text("Types: \(place.types.joined(separator: ", "))")
                        .font(.headline)
                    Text("Vicinity: \(place.vicinity)")
                        .font(.headline)
                    if let isOpenNow = place.opening_hours?.open_now {
                        Text("Open Now: \(isOpenNow ? "Yes" : "No")")
                            .font(.headline)
                    }
                    
                    if let photoReference = place.photos?.first?.photo_reference {
                        // Display the image in the detail view
                        URLImage(imageURL(photoReference: photoReference, maxWidth: 400)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200) // Adjust the size as needed
                        }
                    }
                }
            }
        }
        .navigationTitle(place.name)
    }
}

