//
//  SightsView.swift
//  MySuomiApp
//
//

import SwiftUI


struct SightsView: View {
  // Sample data for demo
  let sights = [
    ("Hollola", "hollola"),
    ("Sight 2", "sight2_image"),
    ("Sight 3", "sight3_image"),
  ]
  
  @State private var likes: [(String,String)] = []
  
  var body: some View {
    NavigationView {
      List {
        ForEach(sights, id: \.0) { sight, imageName in
          NavigationLink(destination: Text("Details for \(sight)")) {
            CardView(title: sight, imageName: imageName, likes: $likes)
          }
          .buttonStyle(PlainButtonStyle())
        }
      }
      .navigationTitle("Sights")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}


struct SightsView_Previews: PreviewProvider {
  static var previews: some View {
    SightsView()
  }
}
