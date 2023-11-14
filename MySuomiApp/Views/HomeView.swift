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
                        self.languageSettings.isFinnish.toggle()
                    }) {
                        Text(languageSettings.isFinnish ? "FIN" : "ENG")
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
                        Button(languageSettings.isFinnish ? "Eat and drink" : "Syö ja juo") {
                            self.selectedMenu = languageSettings.isFinnish ? "Eat and drink" : "Syö ja juo"
                        }
                        Button(languageSettings.isFinnish ? "Sights" : "Nähtävyydet") {
                            self.selectedMenu = languageSettings.isFinnish ? "Sights" : "Nähtävyydet"
                        }
                        Button(languageSettings.isFinnish ? "Fun" : "Pidä hauskaa") {
                            self.selectedMenu = languageSettings.isFinnish ? "Fun" : "Pidä hauskaa"
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
                    TextField("Search", text: $searchText)
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
                    Text(languageSettings.isFinnish ? "Map" : "Kartta")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }

                Spacer()
            }
            //locale for the view based on the language setting
            .environment(\.locale, languageSettings.isFinnish ? Locale(identifier: "fi") : Locale(identifier: "en"))
        }
    }

    func destinationForMenu() -> some View {
        switch selectedMenu {
        case languageSettings.isFinnish ? "Eat and drink" : "Syö ja juo":
            return AnyView(Text(languageSettings.isFinnish ? "Eat and drink" : "Syö ja juo"))
        case languageSettings.isFinnish ? "Sights" : "Nähtävyydet":
            return AnyView(Text(languageSettings.isFinnish ? "Sights" : "Nähtävyydet"))
        case languageSettings.isFinnish ? "Fun" : "Pidät hauskaa":
            return AnyView(Text(languageSettings.isFinnish ? "Fun" : "Pidä hauskaa"))
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

