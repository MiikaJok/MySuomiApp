import SwiftUI
import URLImage
import MapKit

// DetailView displays information about a specific place, including a map view for its location.
struct DetailView: View {
<<<<<<< HEAD
  @EnvironmentObject var languageSettings: LanguageSettings
  let place: Place
  
  @State private var coordinates: CLLocationCoordinate2D?
  @State private var isNavigationActive = false
  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354),
    span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
  )
  
  var onCoordinateUpdate: ((CLLocationCoordinate2D?) -> Void)?
  
  var body: some View {
      NavigationView {
       
          if isNavigationActive {
            MapView(region: $region, selectedCoordinate: .constant(coordinates))
              .environmentObject(languageSettings)
              .navigationBarHidden(true)
              .onAppear {
                let updateCallback: (CLLocationCoordinate2D?) -> Void = { updatedCoordinate in
                  self.updateCoordinates(updatedCoordinate)
                }
                updateCallback(coordinates)
              }
          } else {
            List {
              Section(header: Text(LocalizedStringKey("Details for \(place.name)")).font(.title2)) {
                VStack(alignment: .leading, spacing: 10) {
                  if let rating = place.rating {
                    Text(LocalizedStringKey("Rating: \(rating, specifier: "%.1f")"))
                      .font(.headline)
                  } else {
                    Text(LocalizedStringKey("Rating: N/A"))
                      .font(.headline)
                  }
                  
                  let filteredTypes = place.types.filter { $0.lowercased() != "point_of_interest" && $0.lowercased() != "establishment" }
                  Text(LocalizedStringKey("Types: \(filteredTypes.joined(separator: ", "))"))
                    .font(.headline)
                  
                  Text(LocalizedStringKey("Vicinity: \(place.vicinity)"))
                    .font(.headline)
                  
                  if let isOpenNow = place.opening_hours?.open_now {
                    Text(LocalizedStringKey("Open Now: \(isOpenNow ? "Yes" : "No")"))
                      .font(.headline)
                      .foregroundColor(isOpenNow ? .green : .red)
                  }
                  
                  if let photoReference = place.photos?.first?.photo_reference {
                    URLImage(imageURL(photoReference: photoReference, maxWidth: 400)) { image in
                      image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                        .frame(height: 200)
                        .padding(.top, 10)
                    }
                  }
                  HStack{
                    Spacer()
                    Button(action: {
                      fetchCoordinates()
                      isNavigationActive = true
                    }) {
                      Text(LocalizedStringKey("Locate Place"))
                        .foregroundColor(.black)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(hex: "E660A5")).shadow(radius: 5))
                    }
                    Spacer()
                  }
=======
    @EnvironmentObject var languageSettings: LanguageSettings
    let place: Place

    // State variables to track coordinates, navigation state, and map region
    @State internal var coordinates: CLLocationCoordinate2D?
    @State private var isNavigationActive = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354),
        span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )

    // Callback closure to notify parent views of coordinate updates
    var onCoordinateUpdate: ((CLLocationCoordinate2D?) -> Void)?

    var body: some View {
        NavigationView {
            if isNavigationActive {
                // MapView for displaying the location when navigation is active
                MapView(region: $region, selectedCoordinate: .constant(coordinates))
                    .environmentObject(languageSettings)
                    .navigationBarHidden(true)
                    .onAppear {
                        // Callback to update coordinates when the view appears
                        let updateCallback: (CLLocationCoordinate2D?) -> Void = { updatedCoordinate in
                            self.updateCoordinates(updatedCoordinate)
                        }
                        updateCallback(coordinates)
                    }
            } else {
                // List of details when not navigating
                List {
                    Section(header: Text(LocalizedStringKey("Details for \(place.name)")).font(.title2)) {
                        VStack(alignment: .leading, spacing: 10) {
                            // Displaying place details, such as rating, types, vicinity, etc.
                            if let rating = place.rating {
                                Text(LocalizedStringKey("Rating: \(rating, specifier: "%.1f")"))
                                    .font(.headline)
                            } else {
                                Text(LocalizedStringKey("Rating: N/A"))
                                    .font(.headline)
                            }

                            let filteredTypes = place.types.filter { $0.lowercased() != "point_of_interest" && $0.lowercased() != "establishment" }
                            Text(LocalizedStringKey("Types: \(filteredTypes.joined(separator: ", "))"))
                                .font(.headline)

                            Text(LocalizedStringKey("Vicinity: \(place.vicinity)"))
                                .font(.headline)

                            if let isOpenNow = place.opening_hours?.open_now {
                                Text(LocalizedStringKey("Open Now: \(isOpenNow ? "Yes" : "No")"))
                                    .font(.headline)
                                    .foregroundColor(isOpenNow ? .green : .red)
                            }

                            if let photoReference = place.photos?.first?.photo_reference {
                                URLImage(imageURL(photoReference: photoReference, maxWidth: 400)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(15)
                                        .frame(height: 200)
                                        .padding(.top, 10)
                                }
                            }
                          HStack{
                            Spacer()
                            Button(action: {
                                fetchCoordinates()
                                isNavigationActive = true
                            }) {
                                Text(LocalizedStringKey("Locate Place"))
                                .foregroundColor(.black)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(hex: "E660A5")).shadow(radius: 5))
                            }
                            Spacer()
                          }
                        }
                        .padding(.horizontal, 15)
                    }

                    .listStyle(InsetGroupedListStyle())
                    .padding()

>>>>>>> 4eaa5a40f4c3eccbede45f8d6db12aec9695036a
                }
                .padding(.horizontal, 15)
              }
              .listStyle(InsetGroupedListStyle())
              .padding()
              
              
            }
            .navigationTitle(place.name)
            .navigationBarBackButtonHidden(false)
            .background(NavigationLink("", destination: EmptyView(), isActive: $isNavigationActive))
            .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
          }
          
        
    }
<<<<<<< HEAD
  }
  
  func fetchCoordinates() {
    let apiKey = APIKeys.googlePlacesAPIKey
    guard !place.place_id.isEmpty else { return }
    let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(place.place_id)&key=\(apiKey)")!
    
    Task {
      do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let detailsResponse = try decoder.decode(PlaceDetailsResponse.self, from: data)
        
        if let location = detailsResponse.result?.geometry?.location {
          coordinates = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
          region.center = coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
          region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
          print("Fetched coordinates: \(coordinates?.latitude ?? 0), \(coordinates?.longitude ?? 0)")
          onCoordinateUpdate?(coordinates)
=======

    // Function to fetch coordinates using Google Places API
    func fetchCoordinates(urlSession: URLSession = URLSession.shared) {
        // Retrieving the API key and ensuring the place ID is not empty
        let apiKey = APIKeys.googlePlacesAPIKey
        guard !place.place_id.isEmpty else { return }
        
        // Constructing the URL for fetching place details
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(place.place_id)&key=\(apiKey)")!

        // Using async/await to perform the network request and handle the response
        Task {
            do {
                // Fetching data from the URL
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                let detailsResponse = try decoder.decode(PlaceDetailsResponse.self, from: data)

                // Extracting and updating coordinates if available
                if let location = detailsResponse.result?.geometry?.location {
                    coordinates = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
                    region.center = coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                    region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    print("Fetched coordinates: \(coordinates?.latitude ?? 0), \(coordinates?.longitude ?? 0)")
                    
                    // Notifying parent views about coordinate updates
                    onCoordinateUpdate?(coordinates)
                }
            } catch {
                print("Error fetching coordinates: \(error)")
            }
>>>>>>> 4eaa5a40f4c3eccbede45f8d6db12aec9695036a
        }
      } catch {
        print("Error fetching coordinates: \(error)")
      }
    }
<<<<<<< HEAD
  }
  
  private func updateCoordinates(_ updatedCoordinate: CLLocationCoordinate2D?) {
    if let updatedCoordinate = updatedCoordinate {
      coordinates = updatedCoordinate
      region.center = updatedCoordinate
      region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
=======

    // Function to update coordinates and region
    private func updateCoordinates(_ updatedCoordinate: CLLocationCoordinate2D?) {
        if let updatedCoordinate = updatedCoordinate {
            coordinates = updatedCoordinate
            region.center = updatedCoordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
>>>>>>> 4eaa5a40f4c3eccbede45f8d6db12aec9695036a
    }
  }
}
