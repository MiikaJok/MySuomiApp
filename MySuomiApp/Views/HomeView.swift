import SwiftUI
import Speech
import MapKit
import URLImage

// The main view of the app
struct HomeView: View {
    // Environment object for language settings
    @EnvironmentObject var languageSettings: LanguageSettings
    // State object for speech recognition
    @StateObject private var speechRecognition = SpeechRecognition()
    
    // State variables for UI interaction and data storage
    @State private var isSearchBarVisible = false
    @State private var searchText = ""
    @State private var selectedMenu: String? = nil
    @State private var isNavigationActive: Bool = false
    @State private var places: [Place] = []
    @State private var searchResults: [Place] = []
    @State private var showRecordingMessage = false
    @State private var currentTabIndex = 0
    @State private var coordinates: CLLocationCoordinate2D?
    
    @Binding var region: MKCoordinateRegion
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Header with language toggle, app title, search bar toggle, and menu button
                    HStack {
                        Spacer().frame(minWidth: 0, maxWidth: 20)
                        // Language toggle button
                        Button(action: {
                            self.languageSettings.isEnglish.toggle()
                        }) {
                            Text(languageSettings.isEnglish ? "ENG" : "FIN")
                                .padding(8)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .padding(8)
                        }
                        Spacer()

                        Button(action: {
                            self.isSearchBarVisible.toggle()
                            // reset searchtext and results when closing the search
                            if !isSearchBarVisible {
                                searchResults.removeAll()
                                searchText = ""
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding()
                                .frame(width: 15, height: 15)

                        }
                        Spacer().frame(maxWidth: 32)
                        // Menu button
                        Menu {
                            // Menu items for different categories
                            Button(action: {
                                selectedMenu = "Eat"
                                isNavigationActive.toggle()
                            }) {
                                Label(
                                    title: { Text(LocalizedStringKey("Eat and drink")) },
                                    icon: { Image(systemName: "fork.knife.circle") }
                                )
                            }
                            
                            Button(action: {
                                selectedMenu = "Sights"
                                isNavigationActive.toggle()
                            }) {
                                Label(
                                    title: { Text(LocalizedStringKey("Sights")) },
                                    icon: { Image(systemName: "eye") }
                                )
                            }
                            
                            Button(action: {
                                selectedMenu = "Accommodation"
                                isNavigationActive.toggle()
                            }) {
                                Label(
                                    title: { Text(LocalizedStringKey("Accommodation")) },
                                    icon: { Image(systemName: "house") }
                                )                            }
                            
                            Button(action: {
                                selectedMenu = "Nature"
                                isNavigationActive.toggle()
                            }) {
                                Label(
                                    title: { Text(LocalizedStringKey("Nature")) },
                                    icon: { Image(systemName: "leaf") }
                                )                            }
                            
                            Button(action: {
                                selectedMenu = "Favorites"
                                isNavigationActive.toggle()
                            }) {
                                Label(
                                    title: { Text(LocalizedStringKey("Favorites")) },
                                    icon: { Image(systemName: "heart.fill") }
                                )
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .padding()
                                .frame(width: 15, height: 15)

                        }
                        Spacer().frame(minWidth: 0, maxWidth: 30)
                    }
                    
                    // Search bar when visible
                    if isSearchBarVisible {
                        HStack {
                            TextField(LocalizedStringKey("Search"), text: $searchText)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .padding()
                                .onChange(of: searchText, perform: { newSearchText in
                                    // Call searchPlaces when text changes
                                    searchPlaces()
                                })
                                .disabled(speechRecognition.isRecording)
                            
                            Button(action: {
                                // Toggle speech recognition
                                if speechRecognition.isRecording {
                                    speechRecognition.stopRecording()
                                    searchText = speechRecognition.recognizedText
                                    showRecordingMessage = false
                                } else {
                                    searchText = ""
                                    speechRecognition.startRecording()
                                    showRecordingMessage = true
                                }
                            }) {
                                Image(systemName: speechRecognition.isRecording ? "mic.fill" : "mic")
                                    .font(.system(size: 20))
                                    .padding()
                                    .foregroundColor(speechRecognition.isRecording ? .red : .blue)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                                    .accessibility(label: Text(LocalizedStringKey("Speech Recognition")))
                            }
                            Spacer(minLength: 32)
                        }
                        
                        // Show recording message if speech recognition is active
                        if showRecordingMessage {
                            Text(LocalizedStringKey("Speech recognition is active. Press mic again after searching to see the result."))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Display search results
                    if isSearchBarVisible && !searchText.isEmpty && searchResults.isEmpty {
                        Text(LocalizedStringKey("No search results"))
                            .foregroundColor(.gray)
                            .padding(.top, 16)
                    } else if isSearchBarVisible && !searchResults.isEmpty {
                        ScrollView {
                            LazyVStack {
                                Section(header: Text(LocalizedStringKey("Search Results"))) {
                                    ForEach(searchResults.indices, id: \.self) { index in
                                        let place = searchResults[index]
                                        NavigationLink(destination: DetailView(place: place)) {
                                            VStack(alignment: .leading) {
                                                Text(place.name)
                                                    .font(.headline)
                                            }
                                            .padding(.vertical, 8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 250) // Set the maximum height as needed
                    }
                    
                    
                    // Image carousel with TabView
                    VStack {
                        ZStack(alignment: .top) {
                            Image("helsinki")
                                .resizable()
                                .scaledToFill()
                                .frame(height: UIScreen.main.bounds.height * 0.3)
                                .clipped()
                                .cornerRadius(15)
                                .padding()
                            Text("MySuomiApp")
                                .padding(8)
                                .font(.title)
                                .bold()
                                .offset(y: 20)
                        }
                        
                        VStack {
                            Text(LocalizedStringKey("Cafes"))
                                .font(.headline)
                            
                            if places.isEmpty {
                                Text(LocalizedStringKey("Loading places..."))
                            } else {
                                TabView(selection: $currentTabIndex) {
                                    Spacer().tag(-1)
                                    ForEach(0..<15, id: \.self) { index in
                                        VStack {
                                            if let photoReference = places[index].photos?.first?.photo_reference {
                                                let url = imageURL(photoReference: photoReference, maxWidth: 800)
                                                let place = places[index]
                                                NavigationLink(destination: DetailView(place: place)) {
                                                    ZStack(alignment: .top) {
                                                        AsyncImage(url: url) { phase in
                                                            switch phase {
                                                            case .success(let image):
                                                                image
                                                                    .resizable()
                                                                    .scaledToFill()
                                                                    .clipped()
                                                                    .frame(height: UIScreen.main.bounds.height * 0.3)
                                                            case .failure:
                                                                Text(LocalizedStringKey("Image not available"))
                                                                
                                                            case .empty:
                                                                ProgressView()
                                                            }
                                                        }
                                                        Text(place.name)
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                            .padding(8)
                                                            .background(Color.black.opacity(0.5))
                                                            .cornerRadius(8)
                                                            .offset(y: 20)
                                                    }
                                                }
                                            }
                                        }
                                        .tag(index)
                                    }
                                    Spacer().tag(places.count)
                                }
                                .tabViewStyle(.page)
                                .indexViewStyle(.page(backgroundDisplayMode: .never))
                                .onChange(of: currentTabIndex) { newIndex in
                                    if newIndex == places.count {
                                        currentTabIndex = 0
                                    } else if newIndex == -1 {
                                        currentTabIndex = places.count - 1
                                    }
                                }
                                
                                .accessibilityIdentifier("CarouselView")
                                
                            }
                            
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        .onAppear {
                            fetchCafes(within: 1000)
                        }
                        
                    }
                    
                    // Button to see all museums
                    NavigationLink(destination: AllMuseumsView()) {
                        ZStack {
                            // Museum Image
                            Image("museo")
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .frame(height: UIScreen.main.bounds.height * 0.3)
                                .overlay(
                                    // Text overlay on the image
                                    VStack {
                                        Spacer()
                                        Text(LocalizedStringKey("Museums close to you"))
                                            .foregroundColor(.white)
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                            .padding(.bottom, 16)
                                    }
                                        .frame(maxWidth: .infinity)
                                        .background(Color.black.opacity(0.5))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 5)
                        }
                        .frame(width: 200)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Navigation link to the MapView
                    NavigationLink(destination: MapView(region: $region, selectedCoordinate: .constant(coordinates)).environmentObject(languageSettings)) {
                        VStack {
                            Image(systemName: "map.fill") //
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                            
                            Text(LocalizedStringKey("Explore Map"))
                                .foregroundColor(.white)
                                .padding(.top, 8)
                        }
                        .frame(width: 120, height: 120)
                        .background(Color.green)
                        .cornerRadius(16)
                        .padding()
                        .shadow(radius: 5)
                        .navigationBarTitle("", displayMode: .inline)
                        
                    }
                }
                Spacer()
                
                Spacer()
                // Navigation links to specific category views
                    .background(
                        NavigationLink(
                            destination: {
                                if let selectedMenu = selectedMenu {
                                    switch selectedMenu {
                                    case "Eat":
                                        return AnyView(EatView().environmentObject(languageSettings))
                                    case "Sights":
                                        return AnyView(SightsView().environmentObject(languageSettings))
                                    case "Accommodation":
                                        return AnyView(AccommodationView().environmentObject(languageSettings))
                                    case "Nature":
                                        return AnyView(NatureView().environmentObject(languageSettings))
                                    case "Favorites":
                                        return AnyView(FavoritesView().environmentObject(languageSettings))
                                    default:
                                        return AnyView(EmptyView())
                                    }
                                } else {
                                    return AnyView(EmptyView())
                                }
                            }() as AnyView,
                            isActive: $isNavigationActive,
                            label: { EmptyView() }
                        )
                        .hidden()
                        
                        .onAppear {
                            selectedMenu = nil
                            
                        }
                            .opacity(0)
                            .buttonStyle(PlainButtonStyle())
                    )
            }
            .background(Gradient(colors: [.white, Color(hex: "E660A5")]))//pink
            .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
        }
    }
    
    // Function to fetch cafes
    private func fetchCafes(within radius: Int) {
        // Fetches cafes within a specified radius
        let cafeTypes = restaurantTypes.filter { $0.rawValue.lowercased() == "cafe" }
        
        fetchPlaces(for: cafeTypes.map { $0.rawValue }, radius: radius) { fetchedPlaces in
            if let fetchedPlaces = fetchedPlaces {
                // Filter out places with type "lodging"
                self.places = fetchedPlaces.filter { $0.types.contains("lodging") == false }
            }
        }
    }
    
    // Function to search places
    private func searchPlaces() {
        // Searches for places based on the entered text
        Search.searchPlaces(query: searchText) { fetchedPlaces in
            if let fetchedPlaces = fetchedPlaces {
                DispatchQueue.main.async {
                    searchResults = fetchedPlaces
                }
            }
        }
    }
}
