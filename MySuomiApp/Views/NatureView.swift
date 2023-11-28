import SwiftUI
import URLImage


struct NatureView: View {
    @State private var naturePlaces: [Place] = []
    
    var body: some View {
        VStack {
            // Display your nature places here
            List(naturePlaces, id: \.place_id) { place in
                NavigationLink(destination: NatureDetailView(place: place)) {
                    HStack {
                        if let photoReference = place.photos?.first?.photo_reference {
                            // Display the image in the list view
                            URLImage(imageURL(photoReference: photoReference, maxWidth: 100)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            }                        }
                        Text(place.name)
                            .font(.headline)
                            .padding(.trailing, 10)
                        
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onAppear {
                // Fetch nature places when the view appears
                fetchNaturePlaces()
            }
        }
        .navigationTitle("Nature")
    }
    
    func fetchNaturePlaces() {
        // Use the natureTypes array to fetch nature places
        fetchPlaces(for: natureTypes) { places in
            if let places = places {
                // Update the state with the fetched nature places
                naturePlaces = places
            } else {
                // Handle error or display an error message
                print("Failed to fetch nature places")
            }
        }
    }
}

struct NatureDetailView: View {
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
                    Text("Vicinity: \(place.vicinity)")
                        .font(.headline)
                    if let isOpenNow = place.opening_hours?.open_now {
                        Text("Open Now: \(isOpenNow ? "Yes" : "No")")
                            .font(.headline)
                    }
                    
                    if let photoReference = place.photos?.first?.photo_reference {
                        // Display the image in the detail view
                        URLImage(imageURL(photoReference: photoReference, maxWidth: 400)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200) // Adjust the size as needed
                        }
                    }
                }
            }
        }
        .navigationTitle(place.name)
    }
}


