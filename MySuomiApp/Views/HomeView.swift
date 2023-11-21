import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var languageSettings: LanguageSettings // for language tracking
    
    @State private var isSearchBarVisible = false
    @State private var searchText = ""
    @State private var selectedMenu: String? = nil
    
    @State private var cardOffset: CGFloat = 0
    
    @State private var isNavigationActive: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
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
                    
                    // MySuomiApp title
                    Text("MySuomiApp")
                        .padding(8)
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    // Search bar visibility toggle
                    Button(action: {
                        self.isSearchBarVisible.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding()
                    }
                    
                    
                    // Menu button using Menu
                    Menu {
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
                            Label(languageSettings.isEnglish ? "Fun" : "Pidä hauskaa", systemImage: "star")
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3")
                            .padding()
                    }
                }
                
                
                // Toggled search bar style
                if isSearchBarVisible {
                    TextField(languageSettings.isEnglish ? "Search" : "Haku", text: $searchText)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                // Image and carousel of cards
                VStack {
                    Image("helsinki")
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        .clipped()
                    
                    // Carousel of cards
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
                    .frame(height: 150) // Adjust the height as needed
                    .offset(x: cardOffset * -(UIScreen.main.bounds.width - 30))
                }
                .padding()
                
                // Navigation to MapView.swift
                NavigationLink(destination: MapView()) {
                    Text(languageSettings.isEnglish ? "Map" : "Kartta")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Spacer()
                
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
                                        }
                                    }
                                    .onAppear {
                                        selectedMenu = nil // Reset the selection after navigation
                                    }
                                    .opacity(0)
                                    .buttonStyle(PlainButtonStyle())
                                )
                            }
            .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
        }
    }
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
                .environmentObject(LanguageSettings())
        }
    }
}
