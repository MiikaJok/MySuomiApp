
import SwiftUI
import URLImage

struct SightsView: View {
    
    @State private var sightsPlaces: [Place] = []
    
    var body: some View {
        List(sightsPlaces, id: \.place_id) { place in
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
            fetchSightsPlaces()
        }
        .navigationTitle("Sights")
    }
    func fetchSightsPlaces() {
        // Use the sightsTypes array to fetch sights places
        fetchPlaces(for: sightsTypes) { places in
            if let places = places {
                // Update the state with the fetched sights places
                sightsPlaces = places
            } else {
                // Handle error or display an error message
                print("Failed to fetch sights places")
            }
        }
    }
}

struct SightsPlaceDetailView: View {
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

