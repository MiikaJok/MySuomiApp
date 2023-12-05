import SwiftUI
import URLImage
import MapKit
import CoreLocation

struct DetailView: View {
    
    let place: Place
    @State private var coordinates: CLLocationCoordinate2D?
    @State private var selectedPlacemark: MKPlacemark?
    @State private var isNavigationActive = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354),
        span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )

    
    var body: some View {
        NavigationView {
            List {
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
                
                // "Locate Place" button
                Button(action: {
                    fetchCoordinates()
                    isNavigationActive = true
                }) {
                    Text("Locate Place")
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle(place.name)
            .background(
                NavigationLink("", destination: MapView(selectedCoordinate: .constant(coordinates)), isActive: $isNavigationActive)
                    .hidden()
            )
        }
    }
    
    // Function to fetch coordinates for a place
    func fetchCoordinates() {
        let apiKey = APIKeys.googlePlacesAPIKey
        
        guard !place.place_id.isEmpty else {
            print("Error: Place ID is empty")
            return
        }
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(place.place_id)&key=\(apiKey)")!
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                print("Received data from the API.")
                
                let decoder = JSONDecoder()
                let detailsResponse = try decoder.decode(PlaceDetailsResponse.self, from: data)
                
                if let location = detailsResponse.result?.geometry?.location {
                    coordinates = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
                    print("Fetched coordinates: \(coordinates?.latitude ?? 0), \(coordinates?.longitude ?? 0)")
                }
            } catch {
                print("Error fetching coordinates: \(error)")
            }
        }
    }
}
