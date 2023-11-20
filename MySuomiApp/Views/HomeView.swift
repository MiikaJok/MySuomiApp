import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var languageSettings: LanguageSettings // for language tracking
    
    @State private var isSearchBarVisible = false
    @State private var searchText = ""
    @State private var selectedMenu: String? = nil
    
    @State private var cardOffset: CGFloat = 0
    @State private var isNavigationActive: Bool = false
    
    @State private var showEatAndDrink = false
    @State private var showSights = false
    @State private var showFun = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    //button to toggle FIN/ENG
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
                    //search bar visibility toggle
                    Button(action: {
                        self.isSearchBarVisible.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding()
                    }
                    
                    
                    Menu {
                        Button(action: {
                            self.showEatAndDrink.toggle()
                        }) {
                            Text(languageSettings.isEnglish ? "Eat and drink" : "Syö ja juo")
                        }
                        .navigationDestination(isPresented: $showEatAndDrink) {
                            EatView()
                        }
                        
                        Button(action: {
                            self.showSights.toggle()
                        }) {
                            Text(languageSettings.isEnglish ? "Sights" : "Nähtävyydet")
                        }
                        .navigationDestination(isPresented: $showSights) {
                            SightsView()
                        }
                        
                        Button(action: {
                            self.showFun.toggle()
                        }) {
                            Text(languageSettings.isEnglish ? "Fun" : "Pidä hauskaa")
                        }
                        .navigationDestination(isPresented: $showFun) {
                            AccommodationView()
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    
                    
                    //toggled search bar style
                    if isSearchBarVisible {
                        TextField(languageSettings.isEnglish ? "Search" : "Haku", text: $searchText)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    
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
                    
                    //navigation to MapView.swift
                    NavigationLink(destination: MapView()) {
                        Text(languageSettings.isEnglish ? "Map" : "Kartta")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                //locale for the view based on the language setting
                .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
            }
        }
    }
        
        struct HomeView_Previews: PreviewProvider {
            static var previews: some View {
                HomeView()
                    .environmentObject(LanguageSettings())
            }
        }
    }

