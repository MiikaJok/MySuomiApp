import SwiftUI
import URLImage



struct HomeView: View {
    // Environment object for language settings
    @EnvironmentObject var languageSettings: LanguageSettings
    
    // State variables for UI interaction and data storage
    @State private var isSearchBarVisible = false
    @State private var searchText = ""
    @State private var selectedMenu: String? = nil
    
    @State private var isNavigationActive: Bool = false
    @State private var places: [Place] = []
    @State private var searchResults: [Place] = []
    
    // carusel stuff
    @State private var cardOffset: CGFloat = 0
    @State private var selectedCafeIndex: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Header with language toggle, app title, search bar toggle, and menu button
                    HStack {
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
                        
                        Text("MySuomiApp")
                            .padding(8)
                            .font(.title)
                            .bold()
                        
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
                        }
                        
                        Menu {
                            // Menu items for different categories
                            Button(action: {
                                selectedMenu = "Eat"
                                isNavigationActive.toggle()
                            }) {
                                Label(languageSettings.isEnglish ? "Eat and drink" : "Syö ja juo", systemImage: "fork.knife.circle")
                            }
                            
                            Button(action: {
                                selectedMenu = "Sights"
                                isNavigationActive.toggle()
                            }) {
                                Label(languageSettings.isEnglish ? "Sights" : "Nähtävyydet", systemImage: "eye")
                            }
                            
                            Button(action: {
                                selectedMenu = "Accommodation"
                                isNavigationActive.toggle()
                            }) {
                                Label(languageSettings.isEnglish ? "Accommodation" : "Majoitus", systemImage: "house")
                            }
                            
                            Button(action: {
                                selectedMenu = "Nature"
                                isNavigationActive.toggle()
                            }) {
                                Label(languageSettings.isEnglish ? "Nature" : "Luonto", systemImage: "leaf")
                            }
                            Button(action: {
                                selectedMenu = "Favorites" //
                                isNavigationActive.toggle()
                            }) {
                                Label(languageSettings.isEnglish ? "Favorites" : "Suosikit", systemImage: "heart.fill")                             }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .padding()
                        }
                    }
                    
                    // Search bar when visible
                    if isSearchBarVisible {
                        TextField(languageSettings.isEnglish ? "Search" : "Haku", text: $searchText)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .padding()
                            .onChange(of: searchText, perform: { newSearchText in
                                // Call searchPlaces when text changes
                                searchPlaces()
                            })
                    }
                    
                    // Display search results
                    
                    if !searchResults.isEmpty {
                        ScrollView {
                            LazyVStack {
                                Section(header: Text("Search Results")) {
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
                        Image("helsinki")
                            .resizable()
                            .scaledToFill()
                            .frame(height: UIScreen.main.bounds.height * 0.3)
                            .clipped()
                            .padding()
                        
                        VStack {
                            Text("Cafes")
                                .font(.headline)
                            
                            if places.isEmpty {
                                Text("Loading places...")
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(places.prefix(10), id: \.self) { place in
                                            if let imageURL = place.photoURL {
                                                URLImage(imageURL) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 300, height: 200)
                                                        .clipped()
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
                        .onAppear {
                            fetchCafes()
                        }
                    }
                    // Navigation link to the MapView
                    NavigationLink(destination: MapView()) {
                        Text(languageSettings.isEnglish ? "Map" : "Kartta")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Navigation links to specific category views
                        .background(
                            Group {
                                if selectedMenu == "Eat" {
                                    NavigationLink(
                                        destination: EatView(),
                                        isActive: $isNavigationActive,
                                        label: {
                                            EmptyView()
                                        }
                                    )
                                    .hidden()
                                } else if selectedMenu == "Sights" {
                                    NavigationLink(
                                        destination: SightsView(),
                                        isActive: $isNavigationActive,
                                        label: {
                                            EmptyView()
                                        }
                                    )
                                    .hidden()
                                } else if selectedMenu == "Accommodation" {
                                    NavigationLink(
                                        destination: AccommodationView(),
                                        isActive: $isNavigationActive,
                                        label: {
                                            EmptyView()
                                        }
                                    )
                                    .hidden()
                                } else if selectedMenu == "Nature" {
                                    NavigationLink(
                                        destination: NatureView(),
                                        isActive: $isNavigationActive,
                                        label: {
                                            EmptyView()
                                        }
                                    )
                                    .hidden()
                                } else if selectedMenu == "Favorites" {
                                    NavigationLink(
                                        destination: FavoritesView(),
                                        isActive: $isNavigationActive,
                                        label: {
                                            EmptyView()
                                        }
                                    )
                                    .hidden()
                                }
                                
                                
                            }
                                .onAppear {
                                    selectedMenu = nil
                                }
                                .opacity(0)
                                .buttonStyle(PlainButtonStyle())
                        )
                }
                .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
            }
        }
    }
    
    let search = Search()
    
    // Function to fetch cafes
    private func fetchCafes() {
        // Assuming restaurantTypes contains a cafe type
        let cafeTypes = restaurantTypes.filter { $0.rawValue.lowercased() == "cafe" }
        
        fetchPlaces(for: cafeTypes.map { $0.rawValue }) { fetchedPlaces in
            if let fetchedPlaces = fetchedPlaces {
                places = fetchedPlaces
            }
        }
    }
    
    // Function to search places
    private func searchPlaces() {
        Search.searchPlaces(query: searchText) { fetchedPlaces in
            if let fetchedPlaces = fetchedPlaces {
                DispatchQueue.main.async {
                    searchResults = fetchedPlaces
                    // print("Search results: \(searchResults)")
                }
            }
        }
    }
    
    // Preview for HomeView
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
                .environmentObject(LanguageSettings())
        }
    }
}

