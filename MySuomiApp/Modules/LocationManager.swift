import MapKit
import CoreLocation

/* MapKit enabling and basic functionality from
 https://medium.com/@pblanesp/how-to-display-a-map-and-track-the-users-location-in-swiftui-7d288cdb747e*/

extension MKPlacemark: Identifiable {}

// Responsible for location-related functionalities
final class LocationManager: NSObject, ObservableObject {
    // Handling location services
    private let locationManager = CLLocationManager()
    
    /* Published variables to track search results, suggestions, map region, and error messages*/
    @Published var searchResults: [MKPlacemark] = []
    @Published var suggestions: [MKLocalSearchCompletion] = []
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 60.1695, longitude: 24.9354),
        span: .init(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )
    @Published var errorMessage: String?
    
    // Providing location suggestions
    private var completer: MKLocalSearchCompleter?
    
    // Search query
    private var currentSearchQuery: String = ""
    
    // Initializer for the LocationManager class
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
        
        completer = MKLocalSearchCompleter()
        completer?.delegate = self
    }
    // Function for searching places based on user input
    func searchPlaces(query: String) {
        guard !query.isEmpty else {
            return // Don't perform a search if the query is empty
        }
        completer?.queryFragment = query // Update the completer with the query
    }
    
    // Function to handle the selection of a suggestion
    func handleSuggestionSelection(_ selectedItem: MKLocalSearchCompletion) {
        // Perform a search using MKLocalSearch based on the selected suggestion
        let request = MKLocalSearch.Request(completion: selectedItem)
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Search failed: \(error.localizedDescription)"
            }
        }
    }
    // Setup method to check and request location permissions
    func setup() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            // Only request location when a suggestion is not selected
            guard searchResults.isEmpty else { return }
            
            DispatchQueue.global().async {
                self.locationManager.requestLocation()
            }
            
        case .notDetermined:
            // Request location when authorization is not determined
            locationManager.requestLocation()
            
        case .denied, .restricted:
            errorMessage = "Access denied. Authorize location settings."
            
        default:
            break
        }
    }
}
// Extension of LocationManager to conform to CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Request location when authorization is granted or changed
            locationManager.requestLocation()
            
            // Only proceed if a suggestion is not selected
            guard searchResults.isEmpty else { return }
            
            // Handle other location-related functionality
        case .notDetermined:
            // Wait for the user to respond to the authorization prompt
            break
            
        case .denied, .restricted:
            errorMessage = "Access denied. Authorize location settings."
            
        default:
            break
        }
    }
    // Delegate method called when location manager encounters an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location manager did fail: \(error.localizedDescription)"
    }
    
    // Delegate method called when the location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
    }
}

let searchFilterArray: [String] = [
    "Helsinki", "Vantaa", "Espoo", "Kauniainen", "Sipoo", "Porvoo"
]
// Extension of LocationManager to conform to MKLocalSearchCompleterDelegate
extension LocationManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Update suggestions based on the search filter array
        suggestions = completer.results.filter { suggestion in
            let subtitleLowercased = suggestion.subtitle.lowercased()
            return searchFilterArray.contains { city in
                subtitleLowercased.contains(city.lowercased())
            }
        }
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle completer errors
        print("Completer failed with error: \(error.localizedDescription)")
    }
    
    func completerDidFinish(_ completer: MKLocalSearchCompleter) {
        // If completer finishes, perform a search using the current query
        searchPlaces(query: currentSearchQuery)
    }
}

