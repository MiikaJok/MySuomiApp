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
    let rating: Double?
    let types: [String]
    let vicinity: String
    let opening_hours: OpeningHours?
    let photos: [Photo]?
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
    case spa
    case movie_theater
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
let defaultRadius: Int = 100
let restaurantTypes: [PlaceType] = [.bar, .restaurant, .night_club, .bakery, .cafe]
let sightsTypes: [PlaceType] = [.zoo, .park, .museum, .tourist_attraction, .amusement_park, .church, .library, .stadium, .aquarium, .university, .art_gallery]
let accommodationTypes: [PlaceType] = [.lodging]
let natureTypes: [PlaceType] = [.rv_park, .campground]

// Use the pipe character "|" as the separator when joining place types
let restaurantTypesString = restaurantTypes.map { $0.rawValue }.joined(separator: "|")
let sightsTypesString = sightsTypes.map { $0.rawValue }.joined(separator: "|")
let accommodationTypesString = accommodationTypes.map { $0.rawValue }.joined(separator: "|")
let natureTypesString = natureTypes.map { $0.rawValue }.joined(separator: "|")

// Function to fetch places from the Google Places API
func fetchPlaces(for typeStrings: [String], completion: @escaping ([Place]?) -> Void) {
    let apiKey = APIKeys.googlePlacesAPIKey
    
    // Base URL for the Google Places API nearby search
    let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    
    // Base location for the search
    let baseLocation = "\(defaultLatitude),\(defaultLongitude)"
    
    // Construct the complete URL for the API request
    var components = URLComponents(string: baseUrl)
    components?.queryItems = [
        URLQueryItem(name: "location", value: baseLocation),
        URLQueryItem(name: "radius", value: "\(defaultRadius)"),
        URLQueryItem(name: "key", value: apiKey),
        URLQueryItem(name: "type", value: typeStrings.joined(separator: "|"))
    ]
    
    // Validate and create a URL from the constructed string
    guard let url = components?.url else {
        print("Invalid URL")
        completion(nil)
        return
    }
    
    print("Fetching places from URL: \(url)")
    
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
                        vicinity: apiPlace.vicinity,
                        opening_hours: apiPlace.opening_hours,
                        photos: apiPlace.photos
                    )
                }
                
                print("Fetched \(places.count) places.")
                print("Received data size: \(data.count) bytes")

                
                // Call the completion handler with the mapped places
                completion(places)
            } catch {
                print("Error fetching or decoding JSON: \(error)")
                completion(nil)
            }
        } catch {
            print("Error: \(error)")
            completion(nil)
        }
    }
}

