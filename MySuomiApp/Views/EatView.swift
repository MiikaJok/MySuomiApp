import SwiftUI
import URLImage

struct EatView: View {
    @State private var restaurantPlaces: [Place] = []
    
    var body: some View {
        List(restaurantPlaces, id: \.place_id) { place in
            NavigationLink(destination: EatDetailView(place: place)) {
                HStack {
                    if let photoReference = place.photos?.first?.photo_reference {
                        // Display the image in the list view
                        URLImage(imageURL(photoReference: photoReference, maxWidth: 100)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        }
                    }
                    Text(place.name)
                        .font(.headline)
                        .padding(.trailing, 10)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            fetchRestaurantPlaces()
        }
        .navigationTitle("Restaurants")
    }
    func fetchRestaurantPlaces() {
        // Use the restaurantsTypes array to fetch restaurant places
        fetchPlaces(for: restaurantTypes) { places in
            if let places = places {
                // Update the state with the fetched restaurant places
                restaurantPlaces = places
            } else {
                // Handle error or display an error message
                print("Failed to fetch restaurant places")
            }
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

// Helper function to construct the image URL using the photo reference and maxWidth
func imageURL(photoReference: String, maxWidth: Int) -> URL {
    let apiKey = APIKeys.googlePlacesAPIKey
    let baseURL = "https://maps.googleapis.com/maps/api/place/photo"
    let url = "\(baseURL)?maxwidth=\(maxWidth)&photoreference=\(photoReference)&key=\(apiKey)"
    return URL(string: url)!
}
