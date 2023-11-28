import Foundation

struct Search {
    struct Location: Codable {
        let lat: Double
        let lng: Double
    }

    struct Place: Codable {
        var name: String
        let place_id: String
        let rating: Double?
        let types: [String]
        let vicinity: String
    }

    struct PlacesResponse: Codable {
        let results: [Place]
    }

    enum PlaceType: String {
        case restaurant, bar, lodging, cafe, park, museum, tourist_attraction, zoo, spa, movie_theater, aquarium, bakery, campground, night_club, amusement_park, church, library, stadium, rv_park, university, art_gallery
        // Add more types as needed
    }

    let defaultLatitude: Double = 60.1695
    let defaultLongitude: Double = 24.9354
    let defaultRadius: Int = 10000

    let restaurantTypes: [PlaceType] = [.bar, .restaurant, .night_club, .bakery, .cafe]

    func fetchPlaces(for types: [PlaceType], completion: @escaping (Result<[Place], Error>) -> Void) {
           let apiKey = APIKeys.googlePlacesAPIKey
           let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
           let baseLocation = "\(defaultLatitude),\(defaultLongitude)"
           let placeTypesString = types.map { $0.rawValue }.joined(separator: "|")

           var components = URLComponents(string: baseUrl)
           components?.queryItems = [
               URLQueryItem(name: "location", value: baseLocation),
               URLQueryItem(name: "radius", value: "\(defaultRadius)"),
               URLQueryItem(name: "key", value: apiKey),
               URLQueryItem(name: "type", value: placeTypesString)
           ]

           guard let url = components?.url else {
               print("Invalid URL")
               completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
               return
           }

           Task {
               do {
                   let (data, _) = try await URLSession.shared.data(from: url)
                   let decoder = JSONDecoder()
                   let response = try decoder.decode(PlacesResponse.self, from: data)
                   let places = response.results
                   completion(.success(places))
               } catch {
                   print("Error: \(error)")
                   completion(.failure(error))
               }
           }
       }

       func searchPlaces(query: String, completion: @escaping ([Place]?) -> Void) {
           fetchPlaces(for: restaurantTypes) { result in
               switch result {
               case .success(let places):
                   let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                   guard !trimmedQuery.isEmpty else {
                       completion(nil)
                       return
                   }

                   let filteredPlaces = places.filter { $0.name.localizedCaseInsensitiveContains(trimmedQuery) }
                   completion(filteredPlaces)

               case .failure(let error):
                   print("Error fetching places: \(error)")
                   completion(nil)
               }
           }
       }
   }
