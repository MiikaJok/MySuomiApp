import Foundation

// Structure to represent a location
struct Location: Codable {
    let lat: Double
    let lng: Double
}

// Structure to represent a place
struct Place: Codable {
    var name: String
    let place_id: String
    let rating: Double
    let types: [String]
    let vicinity: String
}

struct PlacesResponse: Codable {
    let results: [Place]
}

// Enum to represent place types
enum PlaceType: String {
    case restaurant
    case bar
    case lodging
    case cafe
    case park
    case shopping_mall
    case museum
    case tourist_attraction
    case zoo
    case spa
    case movie_theater
    case aquarium
    case bakery
    case campground
    // Add more types as needed
}

// Constants for default values
let defaultLatitude: Double = 60.1695
let defaultLongitude: Double = 24.9354
let defaultRadius: Int = 100000
let defaultPlaceTypes: [PlaceType] = [.restaurant, .bar]

// Function to fetch places from the Google Places API
func fetchPlaces(completion: @escaping ([Place]?) -> Void) {
    let apiKey = APIKeys.googlePlacesAPIKey
    
    // Base URL for the Google Places API nearby search
    let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    
    // Base location for the search
    let baseLocation = "\(defaultLatitude),\(defaultLongitude)"
    
    // Combine multiple types using a pipe (|)
    let types = defaultPlaceTypes.map { $0.rawValue }.joined(separator: "|")
    
    // Construct the complete URL for the API request
    var components = URLComponents(string: baseUrl)
    components?.queryItems = [
        URLQueryItem(name: "location", value: baseLocation),
        URLQueryItem(name: "radius", value: "\(defaultRadius)"),
        URLQueryItem(name: "key", value: apiKey),
        URLQueryItem(name: "type", value: types)
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
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Decode the JSON response using JSONDecoder
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(PlacesResponse.self, from: data)
                
                // Map API response to custom Place struct
                let places = response.results.map { apiPlace -> Place in
                    return Place(
                        name: apiPlace.name,
                        place_id: apiPlace.place_id,
                        rating: apiPlace.rating,
                        types: apiPlace.types,
                        vicinity: apiPlace.vicinity
                        
                    )
                }
                
                // Call the completion handler with the mapped places
                completion(places)
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
