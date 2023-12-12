import SwiftUI
import URLImage
import CoreData

// show all museums
struct AllMuseumsView: View {
    @State private var museumPlaces: [Place] = []
    @State private var hasFetchedData = false // Flag to track whether data has been fetched
    @EnvironmentObject var languageSettings: LanguageSettings

    var body: some View {
        List(museumPlaces, id: \.place_id) { museum in
            NavigationLink(destination: DetailView(place: museum).environmentObject(languageSettings)) {
                HStack {
                    // Display each museum as a card
                    CardView(title: museum.name, imageURL: imageURL(photoReference: museum.photos?.first?.photo_reference ?? "", maxWidth: 100))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationBarTitle("", displayMode: .inline)
        .onAppear {
            // Fetch data only if it hasn't been fetched before
            if !hasFetchedData {
                fetchAndSaveMuseumPlaces()
                hasFetchedData = true
            }
        }
    }

    // Modified function to fetch and save museum places
    func fetchAndSaveMuseumPlaces() {
        // Fetch existing places from Core Data
        let existingPlaces = PersistenceController.shared.fetchPlaces()

        // Create a set to store unique places
        var uniquePlaces: Set<Place> = Set(existingPlaces)

        // Create a dispatch queue to synchronize access to uniquePlaces
        let queue = DispatchQueue(label: "MySuomiApp.uniquePlacesQueue")

        // Create a dispatch group to wait for the fetch to complete
        let dispatchGroup = DispatchGroup()

        // Fetch places of type museum
        dispatchGroup.enter() // Enter the group before starting the fetch
        fetchPlaces(for: ["museum"], radius: 1000) { places in
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
                print("Failed to fetch museum places")
            }
        }

        // Notify when the fetch is complete
        dispatchGroup.notify(queue: .main) {
            // Convert the set back to an array and update the state
            let sortedPlaces = Array(uniquePlaces).sorted(by: { $0.name < $1.name })
            museumPlaces = sortedPlaces
        }
    }
}
