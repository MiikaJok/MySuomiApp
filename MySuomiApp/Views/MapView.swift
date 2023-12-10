import SwiftUI
import MapKit
import CoreData
import CoreLocation

/*
 MapView struct that represents the SwiftUI view displaying the map and search functionality
 */
struct MapView: View {
    // Location-related functionalities manager
    @StateObject var manager = LocationManager()
    
    // Language settings object
    @EnvironmentObject var languageSettings: LanguageSettings
    
    // State variables to control search, suggestions, coordinates and menu
    @State private var selectedMenu: String? = nil
    @State private var places: [Place] = []
    @State private var currentTabIndex = 0
    @State private var searchText = ""
    @State private var selectedPlace: MKLocalSearchCompletion?
    @State private var currentCoordinate: CLLocationCoordinate2D?
    @State private var selectedFromSuggestion = false
    @State private var selectedPlacemark: MKPlacemark?
    @State private var dismissOverlay = false
    
    
    //keeping track of the region,coordinates when views are updates
    @Binding var region: MKCoordinateRegion
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("MySuomiApp")
                        .padding(8)
                        .font(.title)
                        .foregroundColor(Color(hex: "33703C"))//green
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding([.leading, .trailing], 16)
                        .padding(.top, 8)
                }
                
                // Search bar and suggestion list
                VStack {
                    TextField(LocalizedStringKey("Search"), text: $searchText)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "B1D4FC"), lineWidth: 4) // Light blue border
                        )
                        .disableAutocorrection(true)
                        .foregroundColor(.black)
                        .padding([.leading, .trailing], 16)
                        .onChange(of: searchText) { newSearchText in
                            if !selectedFromSuggestion {
                                if newSearchText.isEmpty {
                                    manager.suggestions.removeAll()
                                } else {
                                    manager.searchPlaces(query: newSearchText)
                                }
                            }
                            selectedFromSuggestion = false
                        }
                    
                    // Suggestions list based on search
                    if !manager.suggestions.isEmpty {
                        List(manager.suggestions, id: \.self) { suggestion in
                            Button(action: {
                                selectedPlace = suggestion
                                searchText = "\(suggestion.title), \(suggestion.subtitle)"
                                manager.suggestions.removeAll()
                                selectedFromSuggestion = true
                                
                            }) {
                                Text("\(suggestion.title), \(suggestion.subtitle)")
                            }
                            .listRowBackground(Color(hex: "B1D4FC")) // Light blue
                            
                        }
                        .listStyle(GroupedListStyle())
                        .padding([.leading, .trailing], 16)
                    }
                }
                
                // Map view display based on search results
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: manager.searchResults) { place in
                    MapMarker(coordinate: place.coordinate, tint: Color(hex: "33703C"))// green
                    
                }
                .onTapGesture {
                    // When a new place is tapped, show the overlay
                    if let tappedPlace = manager.searchResults.first,
                        hasAddressInformation(placemark: tappedPlace) {
                        selectedPlacemark = tappedPlace
                        dismissOverlay = false
                    }
                }
                
                .onChange(of: searchText) { newSearchText in
                    // Update selectedPlacemark based on searchText
                    if let newSelectedPlace = manager.searchResults.first(where: { $0.name == newSearchText }) {
                        selectedPlacemark = newSelectedPlace
                    }
                    // Hide the overlay when searchText changes
                    dismissOverlay = true
                }
                
                .gesture(
                    // Tap gesture to hide the overlay when tapped outside
                    TapGesture()
                        .onEnded { _ in
                            withAnimation {
                                // Update selectedPlacemark and dismissOverlay simultaneously
                                if let tappedPlace = manager.searchResults.first {
                                    selectedPlacemark = tappedPlace
                                }
                                dismissOverlay.toggle()
                            }
                        }
                )
                .overlay(
                    ZStack {
                        if let placemark = selectedPlacemark {
                            // Transparent background behind the overlay
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        // Update selectedPlacemark and dismissOverlay simultaneously
                                        if let tappedPlace = manager.searchResults.first {
                                            selectedPlacemark = tappedPlace
                                        }
                                        dismissOverlay.toggle()
                                    }
                                }
                            
                            // PlaceDetailSheet overlay
                            PlaceDetailSheet(placemark: placemark)
                                .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.35)
                                .background(Color(hex: "B1D4FC")) // light blue
                                .cornerRadius(16)
                                .offset(y: dismissOverlay ? UIScreen.main.bounds.height : -UIScreen.main.bounds.height * 0.2)
                                .edgesIgnoringSafeArea(.bottom)
                                .padding(.horizontal, 8)
                                .onTapGesture {
                                    withAnimation {
                                        dismissOverlay = true
                                    }
                                }
                        }
                    }
                )
                
                .onAppear {
                    
                    print("Map onAppear - Rendered Region: \(region)")
                    // Set the initial region based on manager.region
                    currentCoordinate = selectedCoordinate ?? CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354)
                    manager.region.center = currentCoordinate!
                    manager.region.span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
                    manager.setup()
                    // Additional setup or operations can be done here
                    print("Location authorization completed")
                }
                .onChange(of: selectedCoordinate) { newCoordinate in
                    withAnimation(.easeIn) {
                        updateRegion(with: newCoordinate)
                        manager.searchResults.removeAll()
                        if let selectedCoordinate = newCoordinate {
                            let locationPlacemark = MKPlacemark(coordinate: selectedCoordinate)
                            manager.searchResults.append(locationPlacemark)
                        }
                    }
                }
            }
            .frame(width: 400, height: 600)
            .foregroundColor(.black)
            .padding(.bottom, 16)
            Spacer()
            
            // Navigate to selected place
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
                        // Show the overlay card
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
            
            VStack {
                Text(LocalizedStringKey("Bars"))
                    .font(.headline)
                    .foregroundColor(Color(hex: "33703C")) // green
                
                if places.isEmpty {
                    Text(LocalizedStringKey("Loading places..."))
                        .foregroundColor(Color(hex: "33703C")) // green
                    
                } else {
                    // CarouselView to display places
                    TabView(selection: $currentTabIndex) {
                        Spacer().tag(-1)
                        ForEach(0..<15, id: \.self) { index in
                            VStack {
                                if let photoReference = places[index].photos?.first?.photo_reference {
                                    let url = imageURL(photoReference: photoReference, maxWidth: 800)
                                    let place = places[index]
                                    // NavigationLink to detail view
                                    NavigationLink(destination: DetailView(place: place)) {
                                        // Image and text overlay
                                        ZStack(alignment: .top) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .clipped()
                                                        .frame(height: UIScreen.main.bounds.height * 0.3)
                                                case .failure:
                                                    Text(LocalizedStringKey("Image not available"))
                                                        .foregroundColor(.white)
                                                case .empty:
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "33703C"))) // Green
                                                }
                                            }
                                            Text(place.name)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.black.opacity(0.5))
                                                .cornerRadius(8)
                                                .offset(y: 20)
                                        }
                                    }
                                }
                            }
                            .tag(index)
                        }
                        Spacer().tag(places.count)
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .never))
                    .onChange(of: currentTabIndex) { newIndex in
                        if newIndex == places.count {
                            currentTabIndex = 0
                        } else if newIndex == -1 {
                            currentTabIndex = places.count - 1
                        }
                    }
                    .accessibilityIdentifier("CarouselView")
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.3)
            .onAppear {
                fetchBars()
            }
            .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
        }
    }
    //function to check if the placemark is done from MapKit search or coordinates
    private func hasAddressInformation(placemark: MKPlacemark) -> Bool {
        return placemark.thoroughfare != nil || placemark.locality != nil || placemark.postalCode != nil || placemark.isoCountryCode != nil
    }

    //fetch bars and filter out places with type "lodging"
    private func fetchBars() {
        let barTypes = restaurantTypes.filter { $0.rawValue.lowercased() == "bar" }
        
        fetchPlaces(for: barTypes.map { $0.rawValue }) { fetchedPlaces in
            if let fetchedPlaces = fetchedPlaces {
                // Filter out places with type "lodging"
                places = fetchedPlaces.filter { $0.types.contains("lodging") == false }
            }
        }
    }
    
    //update the region based on the received coordinate
    private func updateRegion(with coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            region.center = coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }
}
// Extension to make CLLocationCoordinate2D equatable
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct PlaceDetailSheet: View {
    
    // Language settings object
    @EnvironmentObject var languageSettings: LanguageSettings
    var placemark: MKPlacemark
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(placemark.name ?? "")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 3)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                
                // Additional Address Information
                Text(LocalizedStringKey("Street:"))
                    .bold()
                    .padding(.bottom, 1)
                Text("\(placemark.thoroughfare ?? "")")
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.bottom, 3)
                
                Text(LocalizedStringKey("City:"))
                    .bold()
                    .padding(.bottom, 1)
                Text("\(placemark.locality ?? "")")
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.bottom, 3)
                Text(LocalizedStringKey("Postal Code:"))
                    .bold()
                    .padding(.bottom, 1)
                Text("\(placemark.postalCode ?? "")")
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.bottom, 3)
                Text(LocalizedStringKey("Country Code:"))
                    .bold()
                    .padding(.bottom, 1)
                Text("\(placemark.isoCountryCode ?? "")")
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.bottom, 3)
            }
            .padding()
        }
        .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))

    }
}
