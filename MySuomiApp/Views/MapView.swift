
//
//  MapView.swift
//  MySuomiApp

import SwiftUI
import MapKit

/*MapView struct that represents the SwiftUI view displaying the map and search functionality*/
struct MapView: View {
    //location related functionalities manager
    @StateObject var manager = LocationManager()
    //language settings object
    @EnvironmentObject var languageSettings: LanguageSettings
    //state variables to control,search and suggestions
    @State private var searchText = ""
    @State private var showSuggestions = false
    @State private var selectedPlace: MKLocalSearchCompletion?
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    //ENG/FIN toggle button
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
                    
                    Text("MySuomiApp")
                        .padding(8)
                        .font(.title)
                        .bold()
                    Spacer()
                }
                //Zoom in button
                Button(action: {
                    self.manager.region.span.latitudeDelta /= 2
                    self.manager.region.span.longitudeDelta /= 2
                }) {
                    Text("Zoom In")
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                        .padding(8)
                }
                //Zoom out button
                Button(action: {
                    self.manager.region.span.latitudeDelta *= 2
                    self.manager.region.span.longitudeDelta *= 2
                }) {
                    Text("Zoom Out")
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                        .padding(8)
                }
                //open up a popover to search from map
                HStack {
                    Button(action: {
                        showSuggestions.toggle()
                    }) {
                        Text("Search")
                    }
                    .padding()
                    .popover(isPresented: $showSuggestions, arrowEdge: .bottom) {
                        VStack {
                            TextField(languageSettings.isEnglish ? "Search" : "Haku", text: $searchText)
                                .padding()
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .onChange(of: searchText, perform: { newSearchText in
                                    manager.searchPlaces(query: newSearchText)
                                })
                            //suggestion list based on search
                            ScrollView {
                                ForEach(manager.suggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        searchText = suggestion.title
                                        showSuggestions = false
                                        selectedPlace = suggestion
                                    }) {
                                        Text("\(suggestion.title), \(suggestion.subtitle)")
                                    }
                                }
                            }
                        }
                    }
                }
                //map view display based on search results
                Map(coordinateRegion: $manager.region, showsUserLocation: true, annotationItems: manager.searchResults) { place in
                    MapMarker(coordinate: place.coordinate, tint: .blue)
                }
                .animation(.easeIn)
            }
            .frame(width: 400, height: 700)
            //setting locale based on language prefs
            .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
            //navigate to selected place from search
            .onChange(of: selectedPlace) { newPlace in
                guard let newPlace = newPlace else { return }
                //updates search text with selected place
                searchText = newPlace.title
                
                // Create a new MKLocalSearch.Request with the selected place
                let request = MKLocalSearch.Request(completion: newPlace)
                let search = MKLocalSearch(request: request)
                //start search to get detailed info
                search.start { response, error in
                    guard let placemark = response?.mapItems.first?.placemark else { return }
                    //updates region to focus on the selected place
                    let selectedCoordinate = placemark.coordinate
                    manager.region.center = selectedCoordinate
                    manager.region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                }
            }
            Spacer()
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LanguageSettings())
    }
}

