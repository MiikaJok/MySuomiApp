import SwiftUI
import MapKit
import CoreData
import CoreLocation

/*MapView struct that represents the SwiftUI view displaying the map and search functionality*/
struct MapView: View {
    // location related functionalities manager
    @StateObject var manager = LocationManager()
    // language settings object
    @EnvironmentObject var languageSettings: LanguageSettings
    // state variables to control, search, and suggestions
    @State private var searchText = ""
    @State private var selectedPlace: MKLocalSearchCompletion?
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @State private var currentCoordinate: CLLocationCoordinate2D?
    @Binding var region: MKCoordinateRegion
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("MySuomiApp")
                        .padding(8)
                        .font(.title)
                        .bold()
                    Spacer()
                }
                
                // Search bar and suggestion list
                VStack {
                    TextField(LocalizedStringKey("Search"), text: $searchText)
                        .padding()
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: searchText, perform: { newSearchText in
                            manager.searchPlaces(query: newSearchText)
                        })
                        .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
                    
                    // Suggestions list based on search
                    if !manager.suggestions.isEmpty {
                        List(manager.suggestions, id: \.self) { suggestion in
                            Button(action: {
                                
                                selectedPlace = suggestion
                                
                                searchText = "\(suggestion.title), \(suggestion.subtitle)"
                                
                                
                            }) {
                                Text("\(suggestion.title), \(suggestion.subtitle)")
                            }
                        }
                        .listStyle(GroupedListStyle())
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
                // Map view display based on search results
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: manager.searchResults) { place in
                    MapMarker(coordinate: place.coordinate, tint: .blue)
                }
                .onAppear {
                    print("Map onAppear - Rendered Region: \(region)")
                    // Set the initial region based on manager.region
                    currentCoordinate = selectedCoordinate ?? CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354)
                    manager.region.center = currentCoordinate!
                    manager.region.span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
                }
                .onChange(of: selectedCoordinate) { newCoordinate in
                    // Update the region whenever the selectedCoordinate changes
                    updateRegion(with: newCoordinate)
                    print("Map - Updated Region: \(region)")
                    // Remove the existing selected place marker
                    manager.searchResults.removeAll()
                    // Add the updated marker for the selected place
                    if let selectedCoordinate = newCoordinate {
                        let locationPlacemark = MKPlacemark(coordinate: selectedCoordinate)
                        manager.searchResults.append(locationPlacemark)
                    }
                }
                .animation(.easeIn)
            }
            .frame(width: 400, height: 700)
            // Navigate to selected place from search
            .onChange(of: selectedPlace) { newPlace in
                guard let newPlace = newPlace else { return }
                // Create a new MKLocalSearch.Request with the selected place
                let request = MKLocalSearch.Request(completion: newPlace)
                let search = MKLocalSearch(request: request)
                // Start search to get detailed info
                search.start { response, error in
                    guard let placemark = response?.mapItems.first?.placemark else {
                        print("Failed to get placemark from response")
                        return
                    }
                    // Update the region to focus on the selected place
                    DispatchQueue.main.async {
                        updateRegion(with: placemark.coordinate)
                        print("Map - Updated Region: \(region)")
                    }
                    // Clear existing markers
                    manager.searchResults.removeAll()
                    // Convert the MKLocalSearchCompletion to MKPlacemark
                    let selectedPlacemark = MKPlacemark(coordinate: placemark.coordinate, addressDictionary: placemark.addressDictionary as? [String: Any])
                    // Append the selected placemark to the search results
                    manager.searchResults.append(selectedPlacemark)
                }
            }
            
            Spacer()
                
        }
        
    }
    // Function to update the region based on the received coordinate
    private func updateRegion(with coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            region.center = coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }
}
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

