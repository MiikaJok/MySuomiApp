//
//  MapView.swift
//  MySuomiApp
//
//Created by iosdev on 14.11.2023.
//

import SwiftUI
import MapKit

// SwiftUI View for displaying the map and related UI elements
struct MapView: View {
    // LocationManager instance to manage location-related functionality
    @StateObject var manager = LocationManager()
    
    // EnvironmentObject for language settings
    @EnvironmentObject var languageSettings: LanguageSettings
    
    // State variable to store search text
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            // Header with language toggle and app title
            HStack {
                // FIN/ENG toggle
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
            
            // Zoom In Button
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
            
            // Zoom Out Button
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
            
            // Search TextField
            TextField(languageSettings.isEnglish ? "Search" : "Haku", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Map View
            Map(coordinateRegion: $manager.region, showsUserLocation: true)
        }
        .frame(width: 400, height: 700)
        .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
        Spacer()
    }
}

// Preview for the MapView
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LanguageSettings())
    }
}

