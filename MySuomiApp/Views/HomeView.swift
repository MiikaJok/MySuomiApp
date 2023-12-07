import SwiftUI
import URLImage
import WebKit
import Speech
import MapKit


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
      // helsinki video
    @State private var isVideoPlaying = true // Auto-play the video
    @State private var isMuted = true
    private let youtubeVideoID = "videon id"
    @State private var coordinates: CLLocationCoordinate2D?
    @Binding var region: MKCoordinateRegion

  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          // Header with language toggle, app title, search bar toggle, and menu button
          HStack {
            Spacer().frame(minWidth: 0, maxWidth: 10)
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
          
          
          
          // Image carousel with ScrollView
          VStack {
            ZStack(alignment: .top){
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
                            Text("Cafes")
                                .font(.headline)
                            
                            if places.isEmpty {
                                Text("Loading places...")
                            } else {
                                TabView(selection: $currentTabIndex) {
                                    Spacer().tag(-1)
                                    
                                    ForEach(places.indices, id: \.self) { index in
                                        let place = places[index]
                                        
                                        VStack {
                                            if let photoReference = place.photos?.first?.photo_reference {
                                                let url = imageURL(photoReference: photoReference, maxWidth: 800)
                                                
                                                NavigationLink(destination: DetailView(place: place)) {
                                                    // Content of the link
                                                    ZStack(alignment: .top) {
                                                        
                                                        // Load the image using AsyncImage
                                                        AsyncImage(url: url) { phase in
                                                            switch phase {
                                                            case .success(let image):
                                                                image
                                                                    .resizable()
                                                                    .scaledToFill()
                                                                    .clipped()
                                                                    .frame(height: UIScreen.main.bounds.height * 0.3)
                                                            case .failure:
                                                                Text("Image not available")
                                                            case .empty:
                                                                ProgressView()
                                                            }
                                                        }
                                                        .frame(height: UIScreen.main.bounds.height * 0.3)
                                                        
                                                        // Display the title of the cafe on top of the image
                                                        Text(place.name)
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                            .padding(8)
                                                            .background(Color.black.opacity(0.5))
                                                            .cornerRadius(8)
                                                            .offset(y: 20)
                                                    }
                                                }

                                                .buttonStyle(PlainButtonStyle())
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
                            fetchCafes()
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
                                        Text(languageSettings.isEnglish ? "Museums close to you" : "Museot lähelläsi")
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
                    NavigationLink(destination: MapView()) {
                        VStack {
                            Image(systemName: "map.fill") //
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                            
                            Text(languageSettings.isEnglish ? "Explore Map" : "Tutustu karttaan")
                                .foregroundColor(.white)
                                .padding(.top, 8)
                        }
                        .frame(width: 120, height: 120) // size of the button
                        .background(Color.green)
                        .cornerRadius(16)
                        .padding()
                        .shadow(radius: 5)

                      } 
                    }
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
                                }
                            }
                                .onAppear {
                                    selectedMenu = nil
                                }
                                .opacity(0)
                                .buttonStyle(PlainButtonStyle())
                        )

                    
                    // Video Section
                    WebView(urlString: "https://www.youtube.com/embed/\(youtubeVideoID)", isMuted: $isMuted)
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        .onAppear {
                            // Auto-play the video when it appears on screen
                            isVideoPlaying = true
                        }

                }
                    
              }
              
            }

        }
    }
    // Function to fetch cafes
    private func fetchCafes() {
        let cafeTypes = restaurantTypes.filter { $0.rawValue.lowercased() == "cafe" }
        
        fetchPlaces(for: cafeTypes.map { $0.rawValue }) { fetchedPlaces in
            if let fetchedPlaces = fetchedPlaces {
                places = fetchedPlaces
            }
            
          }

        .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
      }
    }
    let search = Search()
    
    private func searchPlaces() {
        Search.searchPlaces(query: searchText) { fetchedPlaces in
            if let fetchedPlaces = fetchedPlaces {
                DispatchQueue.main.async {
                    searchResults = fetchedPlaces
                }
            }
        }
        
    struct WebView: UIViewRepresentable {
        let urlString: String
        @Binding var isMuted: Bool
        
        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.navigationDelegate = context.coordinator
            if let url = URL(string: urlString) {
                webView.load(URLRequest(url: url))
            }
            return webView
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, WKNavigationDelegate {
            var parent: WebView
            
            init(_ parent: WebView) {
                self.parent = parent
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

