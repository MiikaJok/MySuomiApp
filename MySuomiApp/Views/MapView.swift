//
//  MapView.swift
//  MySuomiApp
//

import SwiftUI
import MapKit

struct MapView: View {
    
    private let manager = CLLocationManager()

    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    @EnvironmentObject var languageSettings: LanguageSettings //
    
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            Button("Locate me") {
                manager.desiredAccuracy = kCLLocationAccuracyBest
                manager.requestWhenInUseAuthorization()
                manager.startUpdatingLocation()
            }
            
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
                            self.region.span.latitudeDelta /= 2
                            self.region.span.longitudeDelta /= 2
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
                            self.region.span.latitudeDelta *= 2
                            self.region.span.longitudeDelta *= 2
                        }) {
                            Text("Zoom Out")
                                .padding(8)
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(8)
                                .padding(8)
                        }

            TextField(languageSettings.isEnglish ? "Search" : "Haku", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

           
            
            // Map View
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow)
            )
                .frame(width: 400, height: 300)
                
            Spacer()
        }
        .environment(\.locale, languageSettings.isEnglish ? Locale(identifier: "en") : Locale(identifier: "fi"))
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LanguageSettings())
    }
}
