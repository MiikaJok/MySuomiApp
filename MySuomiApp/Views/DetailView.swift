import SwiftUI
import URLImage
import MapKit

// DetailView struct representing the view for displaying details of a place
struct DetailView: View {
    @EnvironmentObject var languageSettings: LanguageSettings
    
    // Place object containing details of the location
    let place: Place
    
    // State variables for managing coordinates, navigation, and map region
    @State private var coordinates: CLLocationCoordinate2D?
    @State private var isNavigationActive = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354),
        span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )
    
    // Callback for updating coordinates externally
    var onCoordinateUpdate: ((CLLocationCoordinate2D?) -> Void)?
    
    var body: some View {
            //conditional modifier to determine when to apply NavigationView
            if isNavigationActive {
                // Display MapView when navigation is active
                MapView(region: $region, selectedCoordinate: .constant(coordinates))
                    .environmentObject(languageSettings)
                    //.navigationBarTitle(place.name)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(
                        leading:
                            Button(action: {
                                isNavigationActive = false
                            }) {
                                Image(systemName: "chevron.left")
                                Text("")
                            }
                    )
                    .onAppear {
                        // Ensure the coordinate update callback is set
                        let updateCallback: (CLLocationCoordinate2D?) -> Void = { updatedCoordinate in
                            self.updateCoordinates(updatedCoordinate)
                        }
                        
                        // Invoke the callback with current coordinates
                        updateCallback(coordinates)
                    }
            } else {
                // Display details in a List when navigation is not active
                List {
                    Section(header: Text(LocalizedStringKey("Details for \(place.name)")).font(.title2)) {
                        VStack(alignment: .leading, spacing: 10) {
                            // Display rating if available, otherwise show N/A
                            if let rating = place.rating {
                                Text(LocalizedStringKey("Rating: \(rating, specifier: "%.1f")"))
                                    .font(.headline)
                            } else {
                                Text(LocalizedStringKey("Rating: N/A"))
                                    .font(.headline)
                            }
                            
                            // Filter out unwanted types and display location types
                            let filteredTypes = place.types.filter { $0.lowercased() != "point_of_interest" && $0.lowercased() != "establishment" }
                            Text(LocalizedStringKey("Types: \(filteredTypes.joined(separator: ", "))"))
                                .font(.headline)
                            
                            // Display location vicinity
                            Text(LocalizedStringKey("Vicinity: \(place.vicinity)"))
                                .font(.headline)
                            
                            // Display whether the location is open now
                            if let isOpenNow = place.opening_hours?.open_now {
                                Text(LocalizedStringKey("Open Now: \(isOpenNow ? "Yes" : "No")"))
                                    .font(.headline)
                                    .foregroundColor(isOpenNow ? .green : .red)
                            }
                            
                            // Display location image if available
                            if let photoReference = place.photos?.first?.photo_reference {
                                URLImage(imageURL(photoReference: photoReference, maxWidth: 400)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                        .padding(.top, 10)
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .listStyle(InsetGroupedListStyle()) // Apply a modern inset grouped style
                    .padding()
                    
                    // "Locate Place" button to activate navigation
                    Button(action: {
                        fetchCoordinates()
                        isNavigationActive = true
                        
                        
                    }) {
                        Text(LocalizedStringKey("Locate Place"))
                            .foregroundColor(.blue)
                    }
                }
                .navigationTitle(place.name)
                .navigationBarBackButtonHidden(false)
                .background(
                    //NavigationLink to trigger navigation
                    NavigationLink("", destination: EmptyView(), isActive: $isNavigationActive)
                )
                .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
            }
        }

    
    
    // Function to fetch coordinates for a place
    func fetchCoordinates() {
        let apiKey = APIKeys.googlePlacesAPIKey
        
        guard !place.place_id.isEmpty else {
            return
        }
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(place.place_id)&key=\(apiKey)")!
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                let decoder = JSONDecoder()
                let detailsResponse = try decoder.decode(PlaceDetailsResponse.self, from: data)
                
                // Extract location coordinates from the response
                if let location = detailsResponse.result?.geometry?.location {
                    coordinates = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
                    region.center = coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                    region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    print("Fetched coordinates: \(coordinates?.latitude ?? 0), \(coordinates?.longitude ?? 0)")
                    
                    // Invoke the callback to update the region in MapView
                    onCoordinateUpdate?(coordinates)
                }
            } catch {
                print("Error fetching coordinates: \(error)")
            }
        }
    }
    
    // Function to update the coordinates and region
    private func updateCoordinates(_ updatedCoordinate: CLLocationCoordinate2D?) {
        if let updatedCoordinate = updatedCoordinate {
            coordinates = updatedCoordinate
            region.center = updatedCoordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }
}
