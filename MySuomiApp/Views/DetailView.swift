import CoreData
import SwiftUI
import URLImage

struct DetailView: View {
    
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
                            .foregroundColor(isOpenNow ? .green : .red)
                    }
                    
                    if let photoReference = place.photos?.first?.photo_reference {
                        // Display the image in the detail view
                        URLImage(imageURL(photoReference: photoReference, maxWidth: 400)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .cornerRadius(10) // Add corner radius for a rounded look
                                .padding(.top, 10) // Add some space between text and image
                        }
                    }
                }
                .padding(.horizontal, 15) // Add horizontal padding for a cleaner look

            }
        }
        .navigationTitle(place.name)
        .listStyle(InsetGroupedListStyle()) // Apply a modern inset grouped style
        .padding()

    }
}

