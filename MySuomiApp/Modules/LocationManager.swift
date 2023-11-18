//
//  LocationManager.swift
//  MySuomiApp
//
//  Created by iosdev on 18.11.2023.
//

import MapKit

/*MapKit enabling and basic functionality from
 https://medium.com/@pblanesp/how-to-display-a-map-and-track-the-users-location-in-swiftui-7d288cdb747e*/

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    // Published variable to track the current map region
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 60.1695, longitude: 24.9354),
        span: .init(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )
    
    @Published var errorMessage: String?
    
    // Initializer for the LocationManager class
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
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

// Extension of LocationManager to conform to CLLocationManagerDelegate
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

