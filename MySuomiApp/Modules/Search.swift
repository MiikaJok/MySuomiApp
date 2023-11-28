import Foundation

struct Search {
    // Function to fetch places from the Google Places API
    static func fetchPlaces(completion: @escaping ([Place]?) -> Void) {
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

    
    static func searchPlaces(query: String, completion: @escaping ([Place]?) -> Void) {
        fetchPlaces { places in
            guard let places = places else {
                completion(nil)
                return
            }

            let filteredPlaces = places.filter { $0.name.lowercased().contains(query.lowercased()) }
            completion(filteredPlaces)
        }
    }
}
