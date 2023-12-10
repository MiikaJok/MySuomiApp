import SwiftUI
import URLImage
import CoreData

struct AccommodationView: View {
    
    @State private var accommodationPlaces: [Place] = []
    @State private var hasFetchedData = false
    @EnvironmentObject var languageSettings: LanguageSettings


    var body: some View {
        // Display your accommodation places here
        List(accommodationPlaces, id: \.place_id) { place in
            NavigationLink(destination: DetailView(place: place).environmentObject(languageSettings)) {
                HStack {
                    CardView(title: place.name, imageURL: imageURL(photoReference: place.photos?.first?.photo_reference ?? "", maxWidth: 100))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationBarTitle("", displayMode: .inline)
        .onAppear {
            // Fetch data only if it hasn't been fetched before
            if !hasFetchedData {
                fetchAndSaveAccommodationPlaces()
                hasFetchedData = true
            }
        }
    }
    
    
    func fetchAndSaveAccommodationPlaces() {
        // Fetch existing places from Core Data
        let existingPlaces = PersistenceController.shared.fetchPlaces()
        
        // Create a set to store unique places
        var uniquePlaces: Set<Place> = Set(existingPlaces)
        
        // Create a dispatch queue to synchronize access to uniquePlaces
        let queue = DispatchQueue(label: "MySuomiApp.uniquePlacesQueue")
        
        // Create a dispatch group to wait for all fetches to complete
        let dispatchGroup = DispatchGroup()
        
        // Iterate over each type in accommodationTypes and fetch places
        for type in accommodationTypes {
            dispatchGroup.enter() // Enter the group before starting a fetch
            
            // Use the type.rawValue to fetch places for the current type
            fetchPlaces(for: [type.rawValue]) { places in
                defer {
                    dispatchGroup.leave() // Leave the group when the fetch is complete
                }
                
                if let places = places {
                    // Perform updates to uniquePlaces inside the synchronized block
                    queue.sync {
                        uniquePlaces.formUnion(places)
                    }
                } else {
                    // Handle error or display an error message
                    print("Failed to fetch restaurant places")
                }
            }
        }
        
        // Notify when all fetches are complete
        dispatchGroup.notify(queue: .main) {
            // Convert the set back to an array and update the state
            let sortedPlaces = Array(uniquePlaces).sorted(by: { $0.name < $1.name })
            accommodationPlaces = sortedPlaces
        }
    }
}
