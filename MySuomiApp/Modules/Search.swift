import Foundation

struct Search {
    static func fetchPlaces(completion: @escaping ([Place]?) -> Void) {
        let apiKey = APIKeys.googlePlacesAPIKey
        let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        let baseLocation = "\(defaultLatitude),\(defaultLongitude)"
        let types = defaultPlaceTypes.map { $0.rawValue }.joined(separator: "|")

        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "location", value: baseLocation),
            URLQueryItem(name: "radius", value: "\(defaultRadius)"),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "type", value: types)
        ]

        guard let url = components?.url else {
            print("Invalid URL")
            completion(nil)
            return
        }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(PlacesResponse.self, from: data)
                    let places = response.results.map { apiPlace -> Place in
                        return Place(
                            name: apiPlace.name,
                            place_id: apiPlace.place_id,
                            rating: apiPlace.rating,
                            types: apiPlace.types,
                            vicinity: apiPlace.vicinity
                        )
                    }
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
