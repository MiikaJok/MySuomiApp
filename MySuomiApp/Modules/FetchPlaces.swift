// FetchPlaces.swift

import Foundation

// Structure to represent a place
struct Place: Codable {
    let name: String
}

// Structure to represent the response from the Google Places API
struct PlacesResponse: Codable {
    let results: [Place]
}

// Function to fetch random places from the Google Places API
func fetchRandomPlaces(completion: @escaping ([Place]?) -> Void) {
    let apiKey = APIKeys.googlePlacesAPIKey
    
    // Base URL for the Google Places API nearby search
    let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    
    // Base location for the search (Example: Latitude, Longitude)
    let baseLocation = "60.1695,24.9354"
    let radius = "10000"
    // Limit the number of results
    let limit = 25
    // Type of place to search for (Example: "bar")
    let type = "bar"
    // Generate random latitude and longitude offsets
    let latOffset = Double.random(in: -0.1...0.1)
    let lonOffset = Double.random(in: -0.1...0.1)
    
    // Create a random location by applying offsets to the base location
    let randomLocation = "\(baseLocation)"
        .components(separatedBy: ",")
        .compactMap { Double($0) }
        .enumerated()
        .map { index, value in
            return index == 0 ? "\(value + latOffset)" : "\(value + lonOffset)"
        }
        .joined(separator: ",")
    
    // Construct the complete URL for the API request
    let urlString = "\(baseUrl)location=\(randomLocation)&radius=\(radius)&key=\(apiKey)&limit=\(limit)&type=\(type)"
    
    // Validate and create a URL from the constructed string
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion(nil)
        return
    }
    
    // Create a URLSession data task to perform the API request
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("Error: \(error)")
            completion(nil)
            return
        }
        
        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }
        
        do {
            // Decode the JSON response using JSONDecoder
            let decoder = JSONDecoder()
            let response = try decoder.decode(PlacesResponse.self, from: data)
            
            // Simplify the response by extracting only the place names
            let simplifiedPlaces = response.results.map { Place(name: $0.name) }
            
            // Call the completion handler with the simplified places
            completion(simplifiedPlaces)
        } catch {
            print("Error decoding JSON: \(error)")
            completion(nil)
        }
    }
    task.resume()
}

