import MapKit

/*MapKit enabling and basic functionality from
 https://medium.com/@pblanesp/how-to-display-a-map-and-track-the-users-location-in-swiftui-7d288cdb747e*/

extension MKPlacemark: Identifiable {}

//responsible for location related functionalities
final class LocationManager: NSObject, ObservableObject {
    //handling locationservices
    private let locationManager = CLLocationManager()
    
    /* Published variables to track search results, suggestions, map region, and error messages*/
    @Published var searchResults: [MKPlacemark] = []
    @Published var suggestions: [MKLocalSearchCompletion] = []
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 60.1695, longitude: 24.9354),
        span: .init(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )
    @Published var errorMessage: String?
    
    //providing location suggestions
    private var completer: MKLocalSearchCompleter?
    
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
        let request = MKLocalSearch.Request()
        
        // Specify the cities you want to search in
        //let cities = ["Helsinki", "Espoo", "Kauniainen", "Vantaa"]
        //let cityQuery = cities.joined(separator: " OR ")
        
        // Combine the user's query with the specified cities
        /*request.naturalLanguageQuery = "(\(query) OR Suomi OR Finland) AND (\(cityQuery))"*/
        request.naturalLanguageQuery = query

        
        //local search and updates the searchResult with placemarks
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            guard let self = self else { return }
            
            if let response = response {
                self.searchResults = response.mapItems.compactMap { $0.placemark }
            }
        }
        
        // Update suggestions using the completer
        completer?.queryFragment = query
    }
    
    
    // Setup method to check and request location permissions
    func setup() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
            
            // Set an error message when location access is denied or restricted
        case .denied, .restricted:
            errorMessage = "Access denied. Authorize location settings."
        default:
            break
        }
    }
}

//Extension of LocationManager to conform to CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            
            // Set an error message when location access is denied or restricted
        case .denied, .restricted:
            errorMessage = "Access denied. Authorize location settings."
        default:
            break
        }
    }
    
    // Delegate method called when location manager encounters an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location manager did failed: \(error.localizedDescription)"
    }
    
    // Delegate method called when the location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update the region to focus on the new location
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}

// Extension of LocationManager to conform to MKLocalSearchCompleterDelegate
extension LocationManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Update suggestions when completer results are updated
        suggestions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle completer errors
        print("Completer failed with error: \(error.localizedDescription)")
    }
}
