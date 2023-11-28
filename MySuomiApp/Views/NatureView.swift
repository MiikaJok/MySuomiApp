import SwiftUI
import URLImage


struct NatureView: View {
    @State private var naturePlaces: [Place] = []
    @State private var hasFetchedData = false
    
    
    var body: some View {
        
        // Display your nature places here
        List(naturePlaces, id: \.place_id) { place in
            NavigationLink(destination: NatureDetailView(place: place)) {
                HStack {
                    CardView(title: place.name, imageURL: imageURL(photoReference: place.photos?.first?.photo_reference ?? "", maxWidth: 100))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            // Fetch data only if it hasn't been fetched before
            if !hasFetchedData {
                fetchNaturePlaces()
                hasFetchedData = true
            }
        }
        
        
        .navigationTitle("Nature")
    }
    
    func fetchNaturePlaces() {
        // Create an array to store fetched places
        var combinedPlaces: [Place] = []
        
        // Iterate over each type in natureTypes and fetch places
        for type in natureTypes {
            // Use the type.rawValue to fetch places for the current type
            fetchPlaces(for: [type.rawValue]) { places in
                if let places = places {
                    // Append the fetched places to the combined array
                    combinedPlaces.append(contentsOf: places)
                    
                    // Update the state with the combined array
                    naturePlaces = combinedPlaces
                } else {
                    // Handle error or display an error message
                    print("Failed to fetch nature places")
                }
            }
        }
    }
    
    
}

struct NatureDetailView: View {
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


