//
//  MySuomiAppApp.swift
//  MySuomiApp
//
//  Created by iosdev on 9.11.2023.
//

import SwiftUI

@main
struct MySuomiAppApp: App {
    @StateObject private var languageSettings = LanguageSettings()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(languageSettings)
        }
    }
}
