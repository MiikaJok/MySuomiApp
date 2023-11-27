// EatView.swift

import SwiftUI
import CoreData

struct EatView: View {
  // Sample data for demo
  let items = [
    ("jeren keittiö", "hollola"),
    ("miikan keittiö", "helsinki"),
    ("Item 3", "hollola"),
  ]
  @State private var likes: [(String,String)] = []
  
  //@ObservedObject var languageSettings: LanguageSettings
  
  var body: some View {
    NavigationView {
      List {
        ForEach(items, id: \.0) { item, imageName in
          NavigationLink(destination: Text("Details for \(item)")) {
            CardView(title: item, imageName: imageName, likes: $likes)
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
