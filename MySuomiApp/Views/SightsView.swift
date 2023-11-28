//
//  SightsView.swift
//  MySuomiApp
//
//

import SwiftUI

struct SightsView: View {
    
    @State private var places: [Place] = []
    
    var body: some View {
        //NavigationView {
            List {
                ForEach(places, id: \.place_id) { place in
                    NavigationLink(destination: NaturePlaceDetailView(place: place)) {
                        Text(place.name)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onAppear {
                // Fetch places when the view appears
                fetchPlaces(for: sightsTypes) { fetchedPlaces in
                    if let fetchedPlaces = fetchedPlaces {
                        // Update the state with fetched places
                        places = fetchedPlaces
                        print("Places fetched successfully: \(places)")
                    } else {
                        print("Failed to fetch places.")
                    }
                }
            }
            .navigationTitle("Sights")
        //}
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct NaturePlaceDetailView: View {
    let place: Place
    
    var body: some View {
        Form {
            Section(header: Text("Details for \(place.name)").font(.title2)) {
                VStack(alignment: .leading, spacing: 10) {
                    if let rating = place.rating {
                        Text("Rating: \(rating, specifier: "%.1f")")
                            .font(.headline)
                    } else {
                        Text("Rating: N/A")
                            .font(.headline)
                    }
                    
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

