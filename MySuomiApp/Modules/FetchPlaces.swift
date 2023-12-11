import Foundation
import MapKit

// Structure to represent a location
struct Location: Codable {
    let lat: Double
    let lng: Double
}

// Structure to represent place details for fetching coordinates
struct PlaceDetailsResponse: Codable {
    let result: PlaceDetails?
}

struct PlaceDetails: Codable {
    let geometry: Geometry?
}

struct Geometry: Codable {
    let location: Location
}


// Structure to represent a place
struct Place: Codable, Hashable {
    var name: String
    let place_id: String
    let rating: Double?
    let types: [String]
    let vicinity: String
    let opening_hours: OpeningHours?
    let photos: [Photo]?
    
    // Computed property to get the URL for the first photo
    var photoURL: URL? {
        guard let photoReference = photos?.first?.photo_reference else {
            return nil
        }
        return imageURL(photoReference: photoReference, maxWidth: 200) // Adjust maxWidth as needed
    }
    
    // Provide a hash value based on the place_id
    func hash(into hasher: inout Hasher) {
        hasher.combine(place_id)
    }
    
    // Implement the equality check for Hashable conformance
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.place_id == rhs.place_id
    }
}

struct OpeningHours: Codable {
    let open_now: Bool?
}

struct Photo: Codable {
    let photo_reference: String
    let width: Int
    let height: Int
}

struct PlacesResponse: Codable {
    let results: [Place]
    let status: String
    let error_message: String?
}

// Enum to represent place types
enum PlaceType: String {
    case restaurant
    case bar
    case lodging
    case cafe
    case park
    case museum
    case tourist_attraction
    case zoo
    case aquarium
    case bakery
    case campground
    case night_club
    case amusement_park
    case church
    case library
    case stadium
    case rv_park
    case university
    case art_gallery
    // Add more types as needed
}

// Constants for default values
let defaultLatitude: Double = 60.1695
let defaultLongitude: Double = 24.9354
let defaultRadius: Int = 5000
let restaurantTypes: [PlaceType] = [.bar, .restaurant, .night_club, .bakery, .cafe]
let sightsTypes: [PlaceType] = [.zoo, .park, .museum, .tourist_attraction, .amusement_park, .church, .library, .stadium, .aquarium, .university, .art_gallery]
let accommodationTypes: [PlaceType] = [.lodging]
let natureTypes: [PlaceType] = [.rv_park, .campground]
let museumTypes: [PlaceType] = [.museum]

// Function to fetch places from the Google Places API
func fetchPlaces(for typeStrings: [String], radius: Int = defaultRadius, completion: @escaping ([Place]?) -> Void) {
    
    guard !typeStrings.isEmpty else {
        print("Error: Empty type array")
        completion(nil)
        return
    }
    
    let apiKey = APIKeys.googlePlacesAPIKey
    
    
    // Base URL for the Google Places API nearby search
    let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    
    // Base location for the search
    let baseLocation = "\(defaultLatitude),\(defaultLongitude)"
    
    // Construct the complete URL for the API request
    var components = URLComponents(string: baseUrl)
    components?.queryItems = [
        URLQueryItem(name: "location", value: baseLocation),
        URLQueryItem(name: "radius", value: "\(radius)"),
        URLQueryItem(name: "key", value: apiKey),
        URLQueryItem(name: "type", value: typeStrings.joined(separator: "|"))
    ]
    
    // Validate and create a URL from the constructed string
    guard let url = components?.url else {
        print("Invalid URL")
        completion(nil)
        return
    }
    
    // Use async/await to perform the API request
    Task {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check for network errors
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error: Invalid response")
                completion(nil)
                return
            }
            
            // Decode the JSON response using JSONDecoder
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(PlacesResponse.self, from: data)
                
                // Check the status and handle errors
                if response.status == "OK" {
                    // Map API response to custom Place struct
                    let places = response.results.map { apiPlace -> Place in
                        return Place(
                            name: apiPlace.name,
                            place_id: apiPlace.place_id,
                            rating: apiPlace.rating,
                            types: apiPlace.types,
                            vicinity: apiPlace.vicinity,
                            opening_hours: apiPlace.opening_hours,
                            photos: apiPlace.photos
                        )
                    }
                    
                    print("Fetched \(places.count) places.")
                    // Call the completion handler with the mapped places
                    completion(places)
                } else {
                    print("Error in API response. Status: \(response.status), Message: \(response.error_message ?? "Unknown error")")
                    completion(nil)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        } catch {
            print("Error: \(error)")
            completion(nil)
        }
    }
}
