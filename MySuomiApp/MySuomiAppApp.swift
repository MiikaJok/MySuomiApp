//
//  MySuomiAppApp.swift
//  MySuomiApp
//
//  Created by iosdev on 9.11.2023.
//

import SwiftUI
import CoreData

@main
struct MySuomiAppApp: App {
  
  let persistenceController = PersistenceController.shared
  
  @StateObject private var languageSettings = LanguageSettings()
  var body: some Scene {
    WindowGroup {
      HomeView()
        .environmentObject(languageSettings)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
