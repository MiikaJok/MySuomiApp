// FetchPlaces.swift

import Foundation

struct Place: Codable {
    let name: String
}

struct PlacesResponse: Codable {
    let results: [Place]
}

func fetchRandomPlaces(completion: @escaping ([Place]?) -> Void) {
    let apiKey = "AIzaSyDY3khBmbbqd7-HIhuSWkugrbmO0kI8PSA"
    let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    let baseLocation = "60.1695,24.9354" // Example: Latitude,Longitude
    let radius = "10000" // Example: 5000 meters
    let limit = 25
    let type = "bar"
    
    // Generate random latitude and longitude offsets
    let latOffset = Double.random(in: -0.1...0.1) // Adjust the range as needed
    let lonOffset = Double.random(in: -0.1...0.1) // Adjust the range as needed
    
    let randomLocation = "\(baseLocation)"
        .components(separatedBy: ",")
        .compactMap { Double($0) }
        .enumerated()
        .map { index, value in
            return index == 0 ? "\(value + latOffset)" : "\(value + lonOffset)"
        }
        .joined(separator: ",")
    
    let urlString = "\(baseUrl)location=\(randomLocation)&radius=\(radius)&key=\(apiKey)&limit=\(limit)&type=\(type)"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion(nil)
        return
    }
    
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
            let decoder = JSONDecoder()
            let response = try decoder.decode(PlacesResponse.self, from: data)
            let simplifiedPlaces = response.results.map { Place(name: $0.name) }
            completion(simplifiedPlaces)
        } catch {
            print("Error decoding JSON: \(error)")
            completion(nil)
        }
    }
    task.resume()
}
