//
//  MapView.swift
//  MySuomiApp
//
//  Created by iosdev on 14.11.2023.
//

import SwiftUI

struct MapView: View {
    @EnvironmentObject var languageSettings: LanguageSettings //for language tracking
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            HStack {
                //FIN/ENG toggle
                Button(action: {
                    self.languageSettings.isFinnish.toggle()
                }) {
                    Text(languageSettings.isFinnish ? "ENG" : "FIN")
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
            TextField(languageSettings.isFinnish ? "Search" : "Haku", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Spacer()
        }
        //locale for the view based on the language setting
        .environment(\.locale, languageSettings.isFinnish ? Locale(identifier: "en") : Locale(identifier: "fi"))
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LanguageSettings())
    }
}

