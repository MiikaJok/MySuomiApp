import SwiftUI

struct HomeView: View {
    @State private var isEnglish = true
    @State private var isSearchBarVisible = false
    @State private var searchText = ""
    @State private var selectedMenu: String? = nil
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.isEnglish.toggle()
                }) {
                    Text(isEnglish ? "FIN" : "ENG")
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(8)
                }
                
                Spacer()
                
                Text("MySuomiApp")
                    .padding(8)
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    self.isSearchBarVisible.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                        .padding()
                }
                
                // Move Menu inside HStack
                Menu {
                    Button("Eat and drink") {
                        self.selectedMenu = "Eat and drink"
                    }
                    Button("Sights") {
                        self.selectedMenu = "Sights"
                    }
                    Button("Fun") {
                        self.selectedMenu = "Fun"
                    }
                } label: {
                    Image(systemName: "list.bullet")
                        .padding()
                }
                .onChange(of: selectedMenu) { newValue in
                    // functionality here
                }
            }
            
            if isSearchBarVisible {
                TextField("Search", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            Image("helsinki")
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .clipped()
            
            NavigationLink(destination: destinationForMenu(), tag: selectedMenu ?? "", selection: $selectedMenu) {
                EmptyView()
            }
            
            Spacer()
        }
    }
    
    func destinationForMenu() -> some View {
        switch selectedMenu {
        case "Eat and drink":
            return AnyView(Text("Eat and drink"))
        case "Sights":
            return AnyView(Text("Sights"))
        case "Fun":
            return AnyView(Text("Fun"))
        default:
            return AnyView(EmptyView())
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

