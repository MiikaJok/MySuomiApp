//
//  AllMuseumsView.swift
//  MySuomiApp
//

import SwiftUI

struct AllMuseumsView: View {
    @State private var places: [Place] = []

    var body: some View {
        List(places, id: \.place_id) { museum in
            NavigationLink(destination: DetailView(place: museum)) {
                HStack {
                    CardView(title: museum.name, imageURL: imageURL(photoReference: museum.photos?.first?.photo_reference ?? "", maxWidth: 100))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("All Museums")
        .onAppear {
            self.fetchMuseums()
        }
    }

    // Function to fetch museums
    private func fetchMuseums() {
        let museumTypes = ["museum"]
        fetchPlaces(for: museumTypes) { fetchedMuseums in
            if let fetchedMuseums = fetchedMuseums {
                DispatchQueue.main.async {
                    self.places = fetchedMuseums
                }
            }
        }
    }
}