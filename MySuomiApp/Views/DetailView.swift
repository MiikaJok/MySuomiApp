import SwiftUI
import URLImage
import MapKit
import CoreLocation

struct DetailView: View {
    
    let place: Place
    @State private var coordinates: CLLocationCoordinate2D?
    @State private var isNavigationActive = false
    @State private var selectedPlacemark: MKPlacemark?
    
    
    var body: some View {
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
            }) {
                Text("Locate Place")
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: Binding(
                get: { coordinates != nil },
                set: { _ in coordinates = nil }
            )) {
                if let coordinates = coordinates {
                    MapView(selectedCoordinate: $coordinates)
                        .onAppear {
                            DispatchQueue.main.async {
                                print("MapView appeared with coordinates: \(coordinates.latitude), \(coordinates.longitude)")
                            }
                        }
                        .background(Color.green) // Add a background color for visibility

                } else {
                    EmptyView()
                }
            }
        }
        .navigationTitle(place.name)
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
                    
                    // Add the DispatchQueue.main.async block here
                    DispatchQueue.main.async {
                        self.isNavigationActive = true
                    }
                }
            } catch {
                print("Error fetching coordinates: \(error)")
            }
        }
    }
}
