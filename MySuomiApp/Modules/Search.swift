import Foundation

struct Search {
    
    static let defaultPlaceTypes: [PlaceType] = [
        .restaurant, .bar, .lodging, .cafe, .park, .museum, .tourist_attraction, .zoo,
        .spa, .movie_theater, .aquarium, .bakery, .campground, .night_club, .amusement_park,
        .church, .library, .stadium, .rv_park, .university, .art_gallery
    ]
    
    static func fetchPlaces(for types: [PlaceType], completion: @escaping ([Place]?) -> Void) {
        let apiKey = APIKeys.googlePlacesAPIKey
        let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        let baseLocation = "\(defaultLatitude),\(defaultLongitude)"
        
        // Use async/await to perform the API requests for each type
        Task {
            var allPlaces: [Place] = []
            
            for type in types {
                var components = URLComponents(string: baseUrl)
                components?.queryItems = [
                    URLQueryItem(name: "location", value: baseLocation),
                    URLQueryItem(name: "radius", value: "\(defaultRadius)"),
                    URLQueryItem(name: "key", value: apiKey),
                    URLQueryItem(name: "type", value: type.rawValue)
                ]
                
                guard let url = components?.url else {
                    print("Invalid URL")
                    completion(nil)
                    return
                }
                
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(PlacesResponse.self, from: data)
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
                    allPlaces.append(contentsOf: places)
                } catch {
                    print("Error fetching or decoding JSON for type \(type.rawValue): \(error)")
                }
            }
            
            // Call the completion handler with the combined places from all types
            completion(allPlaces)
        }
    }
    
    static func searchPlaces(query: String, completion: @escaping ([Place]?) -> Void) {
        fetchPlaces(for: defaultPlaceTypes) { places in
            guard let places = places else {
                completion(nil)
                return
            }
            
            let filteredPlaces = places.filter { place in
                let nameContainsQuery = place.name.lowercased().contains(query.lowercased())
                let typesContainQuery = place.types.contains { $0.lowercased().contains(query.lowercased()) }
                return nameContainsQuery || typesContainQuery
            }
            
            print("Fetched \(filteredPlaces.count) places based on name and type.")
            
            // Create a set of unique places based on place_id
            let uniquePlaces = Array(Set(filteredPlaces))
            completion(uniquePlaces)
        }
    }
}
