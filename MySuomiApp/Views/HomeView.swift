import SwiftUI


struct HomeView: View {
    @EnvironmentObject var languageSettings: LanguageSettings //for language tracking

    @State private var isSearchBarVisible = false
    @State private var searchText = ""
    @State private var selectedMenu: String? = nil

    var body: some View {
        NavigationView {
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
                    //navigation menu content with language dependency
                    Menu {
                        Button(languageSettings.isEnglish ? "Eat and drink" : "Syö ja juo") {
                            self.selectedMenu = languageSettings.isEnglish ? "Eat and drink" : "Syö ja juo"
                        }
                        Button(languageSettings.isEnglish ? "Sights" : "Nähtävyydet") {
                            self.selectedMenu = languageSettings.isEnglish ? "Sights" : "Nähtävyydet"
                        }
                        Button(languageSettings.isEnglish ? "Fun" : "Pidä hauskaa") {
                            self.selectedMenu = languageSettings.isEnglish ? "Fun" : "Pidä hauskaa"
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                            .padding()
                    }
                    .onChange(of: selectedMenu) { newValue in
                        // functionality here
                    }
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
    // testi commit

    func destinationForMenu() -> some View {
        switch selectedMenu {
        case languageSettings.isEnglish ? "Eat and drink" : "Syö ja juo":
            return AnyView(Text(languageSettings.isEnglish ? "Eat and drink" : "Syö ja juo"))
        case languageSettings.isEnglish ? "Sights" : "Nähtävyydet":
            return AnyView(Text(languageSettings.isEnglish ? "Sights" : "Nähtävyydet"))
        case languageSettings.isEnglish ? "Fun" : "Pidät hauskaa":
            return AnyView(Text(languageSettings.isEnglish ? "Fun" : "Pidä hauskaa"))
        default:
            return AnyView(EmptyView())
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LanguageSettings())
    }
}

