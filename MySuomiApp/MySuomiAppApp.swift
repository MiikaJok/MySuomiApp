//
//  MySuomiAppApp.swift
//  MySuomiApp
//
//  Created by iosdev on 9.11.2023.
//

import SwiftUI
import CoreData
import MapKit

@main
struct MySuomiAppApp: App {
    
    let persistenceController = PersistenceController.shared
    @StateObject private var languageSettings = LanguageSettings()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    var body: some Scene {
        WindowGroup {
            HomeView(region: $region)
                .environmentObject(languageSettings)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
