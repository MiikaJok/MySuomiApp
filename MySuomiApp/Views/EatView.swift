// EatView.swift

import SwiftUI

struct EatView: View {
    // Sample data for demo
    let items = [
        ("jeren keittiö", "hollola"),
        ("miikan keittiö", "helsinki"),
        ("Item 3", "hollola"),
    ]

    //@ObservedObject var languageSettings: LanguageSettings

    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.0) { item, imageName in
                    NavigationLink(destination: Text("Details for \(item)")) {
                        CardView(title: item, imageName: imageName)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Restaurants")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        //.environmentObject(languageSettings) // Pass the language settings to EatView

    }
}
