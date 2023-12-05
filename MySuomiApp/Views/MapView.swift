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
    @State private var showSuggestions = false
    @State private var selectedPlace: MKLocalSearchCompletion?
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @State private var currentCoordinate: CLLocationCoordinate2D?
    @State private var selectedPlacemark: MKPlacemark?

        
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // ENG/FIN toggle button
                    Button(action: {
                        self.languageSettings.isEnglish.toggle()
                    }) {
                        Text(languageSettings.isEnglish ? "ENG" : "FIN")
                            .padding(8)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(8)
                    }

                    Text("MySuomiApp")
                        .padding(8)
                        .font(.title)
                        .bold()
                    Spacer()
                }

                // Search bar and suggestion list
                VStack {
                    TextField(languageSettings.isEnglish ? "Search" : "Haku", text: $searchText)
                        .padding()
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: searchText, perform: { newSearchText in
                            manager.searchPlaces(query: newSearchText)
                        })

                    // Suggestions list based on search
                    if !manager.suggestions.isEmpty {
                        List(manager.suggestions, id: \.self) { suggestion in
                            Button(action: {
                                searchText = suggestion.title
                                selectedPlace = suggestion
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
                Map(coordinateRegion: $manager.region, showsUserLocation: true, annotationItems: manager.searchResults) { place in
                    MapMarker(coordinate: place.coordinate, tint: .blue)
                }
                .onAppear {
                    // Set the initial region based on manager.region
                    currentCoordinate = selectedCoordinate ?? CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354)
                    manager.region.center = currentCoordinate!
                    manager.region.span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
                }
                .animation(.easeIn)
            }
            .frame(width: 400, height: 700)
            // Setting locale based on language prefs
            .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
            // Navigate to selected place from search
            .onChange(of: selectedPlace) { newPlace in
                guard let newPlace = newPlace else { return }
                // updates search text with selected place
                searchText = newPlace.title

                // Create a new MKLocalSearch.Request with the selected place
                let request = MKLocalSearch.Request(completion: newPlace)
                let search = MKLocalSearch(request: request)
                // start search to get detailed info
                search.start { response, error in
                    guard let placemark = response?.mapItems.first?.placemark else { return }
                    // updates region to focus on the selected place
                    let selectedCoordinate = placemark.coordinate
                    manager.region.center = selectedCoordinate
                    manager.region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    // Clear existing markers
                    manager.searchResults.removeAll()
                    // Convert the MKLocalSearchCompletion to MKPlacemark
                    let selectedPlacemark = MKPlacemark(coordinate: selectedCoordinate, addressDictionary: placemark.addressDictionary as? [String: Any])
                    // Append the selected placemark to the search results
                    manager.searchResults.append(selectedPlacemark)
                }
            }
            Spacer()
        }
    }

    // Function to fetch details for the selected place
    private func fetchDetailsForSelectedPlace() {
        guard let selectedCoordinate = selectedCoordinate else { return }

        let location = CLLocation(latitude: selectedCoordinate.latitude, longitude: selectedCoordinate.longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                selectedPlacemark = MKPlacemark(placemark: placemark)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(selectedCoordinate: .constant(nil))
            .environmentObject(LanguageSettings())
    }
}
