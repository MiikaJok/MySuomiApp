//
//  AccommodationView.swift
//  MySuomiApp
//

import SwiftUI


struct AccommodationView: View {
  // Sample data for demo
  let accommodations = [
    ("Hotel 1", "hollola"),
    ("Hotel 2", "hollola"),
    ("Hotel 3", "helsinki"),
  ]
  
  @State private var likes: [(String,String)] = []
  
  var body: some View {
    NavigationView {
      List {
        ForEach(accommodations, id: \.0) { accommodation, imageName in
          NavigationLink(destination: Text("Details for \(accommodation)")) {
            CardView(title: accommodation, imageName: imageName, likes: $likes)
          }
          .buttonStyle(PlainButtonStyle())
        }
      }
      .navigationTitle("Accommodations")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}


struct AccommodationView_Previews: PreviewProvider {
  static var previews: some View {
    AccommodationView()
  }
}

