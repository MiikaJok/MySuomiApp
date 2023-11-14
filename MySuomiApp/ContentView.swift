import SwiftUI

struct ContentView: View {
    @State private var isMenuVisible = false

    var body: some View {
        NavigationView {
            VStack {
                // Button to toggle the menu
                Button(action: {
                    withAnimation {
                        self.isMenuVisible.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                        .padding()
                }
                .padding(.top, 20)
                
                Spacer()
                .hoverEffect()

                if isMenuVisible {
                    // Your navigation menu content
                    List {
                        Text("Eat and drink")
                        Text("Sights")
                        Text("fun")
                    }
                    .frame(width: 200)
                    .background(Color.gray)
                }
                Spacer()
            }
            .navigationTitle("SwiftUI Navigation Menu")
            .navigationBarHidden(true) // Hide the default navigation bar
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
