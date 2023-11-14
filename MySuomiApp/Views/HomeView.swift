import SwiftUI

struct HomeView: View {
    @State private var isEnglish = true
    @State private var isSearchBarVisible = false
    @State private var searchText = ""
    @State private var isMenuVisible = false
    
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
                
                Button(action: {
                    withAnimation {
                        self.isMenuVisible.toggle()
                    }
                }) {
                    Image(systemName: "list.bullet")
                        .padding()
                }
            }
            
            if isSearchBarVisible {
                TextField("Search", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            if isMenuVisible {
                NavigationView {
                    List {
                        NavigationLink(destination: Text("Eat and drink")) {
                            Text("Eat and drink")
                        }
                        NavigationLink(destination: Text("Sights")) {
                            Text("Sights")
                        }
                        NavigationLink(destination: Text("Fun")) {
                            Text("Fun")
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .frame(width: 200)
                    .background(Color.clear)
                    .padding()
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            
            
            Image("helsinki")
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .clipped()
            
           
            
            Spacer()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
