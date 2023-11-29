import SwiftUI


struct HomeView: View {
    // Environment object for language settings
    @EnvironmentObject var languageSettings: LanguageSettings
    
    // State variables for UI interaction and data storage
    @State private var isSearchBarVisible = false
    @State private var searchText = ""
    @State private var selectedMenu: String? = nil
    @State private var cardOffset: CGFloat = 0
    @State private var isNavigationActive: Bool = false
    @State private var places: [Place] = []
    @State private var searchResults: [Place] = []
    
    
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
                            .padding()
                            .onChange(of: searchText, perform: { newSearchText in
                                // Call searchPlaces when text changes
                                searchPlaces()
                            })
                    }
                    
                    // Display search results
                    if !searchResults.isEmpty {
                        Section(header: Text("Search Results")) {
                            ForEach(searchResults.indices, id: \.self) { index in
                                let place = searchResults[index]
                                NavigationLink(destination: EatDetailView(place: place)) {
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
                    // Image carousel with TabView
                    VStack {
                        Image("helsinki")
                            .resizable()
                            .scaledToFill()
                            .frame(height: UIScreen.main.bounds.height * 0.3)
                            .clipped()
                        
                        TabView(selection: $cardOffset) {
                            ForEach(0..<5, id: \.self) { index in
                                Image("hollola")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width - 30, height: 150)
                                    .clipped()
                                    .padding(.horizontal, 15)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 150)
                        .offset(x: cardOffset * -(UIScreen.main.bounds.width - 30))
                    }
                    .padding()
                    
                    
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
                                }else if selectedMenu == "Nature" {
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
                }
                .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
            }
        }
    }
    
    let search = Search()

    // Function to search places
       private func searchPlaces() {
           Search.searchPlaces(query: searchText) { fetchedPlaces in
               if let fetchedPlaces = fetchedPlaces {
                   DispatchQueue.main.async {
                       searchResults = fetchedPlaces
                       print("Search results: \(searchResults)")
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
