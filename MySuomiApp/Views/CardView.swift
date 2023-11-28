import SwiftUI
import CoreData

struct CardView: View {
  
  let title: String
  let imageName: String
  @Binding var likes: [(String,String)]
  @State private var isFavorite = false
  
  func checkLike() {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Like")
    request.predicate = NSPredicate(format: "name == %@ AND image == %@", title, imageName)
    
    do {
      if let result = try viewContext.fetch(request) as? [NSManagedObject], !result.isEmpty {
        print(result)
        isFavorite = true
      }
    } catch {
      print("Error: \(error)")
    }
  }
  
  // Inject the managedObjectContext
  @Environment(\.managedObjectContext) private var viewContext
  
  var body: some View {
    HStack {
      Button(action: {
        // Toggle the favorite state
        isFavorite.toggle()
        if isFavorite {
          // Save to CoreData
          saveLikeToCoreData()
        } else {
          // Remove from CoreData
          removeLikeFromCoreData()
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
    .onAppear {
      checkLike()
    }
  }
  
  // Function to save liked item to CoreData
  private func saveLikeToCoreData() {
    let newLikedItem = Like(context: viewContext)
    newLikedItem.name = title
    newLikedItem.image = imageName
    
    do {
      try viewContext.save()
    } catch {
      print("Error saving liked item to CoreData: \(error)")
    }
  }
  
  // Function to remove liked item from CoreData
  private func removeLikeFromCoreData() {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Like")
    request.predicate = NSPredicate(format: "name == %@ AND image == %@", title, imageName)
    
    do {
      if let result = try viewContext.fetch(request) as? [NSManagedObject] {
        for object in result {
          viewContext.delete(object)
        }
        try viewContext.save()
      }
    } catch {
      print("Error removing liked item from CoreData: \(error)")
    }
  }
}
