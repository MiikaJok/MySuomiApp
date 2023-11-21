//
//  CardView.swift
//  MySuomiApp
//

import SwiftUI


struct CardView: View {
    let title: String
    let imageName: String

    var body: some View {
        HStack {
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



