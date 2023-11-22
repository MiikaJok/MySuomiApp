//
//  CardView.swift
//  MySuomiApp
//

import SwiftUI

struct CardView: View{
  
  let title: String
  let imageName: String
  @Binding var likes: [(String,String)]
  @State private var isFavorite = false
  
  var body: some View {
    HStack {
      Button(action: {
        // Toggle the favorite state
        isFavorite.toggle()
        if isFavorite {
          likes.append((title,imageName))
        } else {
          likes.removeAll {$0 == (title,imageName)}
          
        }
        print(likes)
      }) {
        Image(systemName: isFavorite ? "heart.fill" : "heart")
          .foregroundColor(isFavorite ? .red : .gray)
          .font(.system(size: 20))
          .padding(.top, 8)
          .padding(.leading, 8)
      }
      
      Image(imageName)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 80, height: 80)
        .cornerRadius(10)
        .clipped()
      
      VStack(alignment: .leading) {
        Text(title)
          .font(.headline)
          .foregroundColor(.primary)
          .padding(.bottom, 4)
        
        Spacer()
      }
      .padding(.horizontal, 8)
      
      Spacer()
    }
    .cornerRadius(10)
    .shadow(radius: 5)
    .padding(.horizontal, -8)
    .padding(.vertical, 8)
  }
}
