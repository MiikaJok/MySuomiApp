// EatView.swift
import SwiftUI

struct EatView: View {
    @State private var places: [Place] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(places, id: \.place_id) { place in
                    NavigationLink(destination: PlaceDetailView(place: place)) {
                        Text(place.name)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onAppear {
                // Fetch places when the view appears
                fetchPlaces { fetchedPlaces in
                    if let fetchedPlaces = fetchedPlaces {
                        // Update the state with fetched places
                        places = fetchedPlaces
                    }
                }
            }
            .navigationTitle("Restaurants")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct PlaceDetailView: View {
    let place: Place
    
    var body: some View {
        Form {
            Section(header: Text("Details for \(place.name)").font(.title2)) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Rating: \(place.rating, specifier: "%.1f")")
                        .font(.headline)
                    Text("Types: \(place.types.joined(separator: ", "))")
                        .font(.headline)
                    Text("Address: \(place.vicinity)")
                        .font(.headline)
                }
            }
        }
        .navigationTitle(place.name)
    }
}
