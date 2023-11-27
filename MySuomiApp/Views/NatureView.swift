//
//  NatureView.swift
//  MySuomiApp
//
//  Created by iosdev on 27.11.2023.
//

import SwiftUI


struct NatureView: View {
    // Sample data for demo
    let naturePlaces = [
        ("Hotel 1", "hollola"),
        ("Hotel 2", "hollola"),
        ("Hotel 3", "helsinki"),
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(naturePlaces, id: \.0) { nature, imageName in
                    NavigationLink(destination: Text("Details for \(nature)")) {
                        CardView(title: nature, imageName: imageName)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Nature")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct NatureView_Previews: PreviewProvider {
    static var previews: some View {
        NatureView()
    }
}
