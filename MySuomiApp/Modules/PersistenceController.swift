import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Initialize the persistent container with the model name "FavoritesModel"
        container = NSPersistentContainer(name: "FavoritesModel")
        
        // Load persistent stores and handle errors
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    // Function to print likes from CoreData to the console
    func printLikesFromCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Like")
        
        do {
            // Fetch likes from Core Data
            let likes = try container.viewContext.fetch(request) as? [Like]
            
            // Iterate through likes and print name and image
            likes?.forEach { like in
                print("Name: \(like.name ?? ""), Image: \(like.image ?? "")")
            }
        } catch {
            // Handle errors during fetching
            print("Error fetching likes from CoreData: \(error)")
        }
    }
    
    // Fetch places from Core Data
    func fetchPlaces() -> [Place] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Like")
        
        do {
            // Fetch places from Core Data
            let places = try container.viewContext.fetch(request) as? [Place]
            return places ?? []
        } catch {
            // Handle errors during fetching
            print("Error fetching places from CoreData: \(error)")
            return []
        }
    }
    
    // Save places to Core Data
    func savePlaces(_ places: [Place]) {
        for place in places {
            // Create a new Like object for each place
            let newPlace = Like(context: container.viewContext)
            newPlace.name = place.name
            newPlace.image = place.photos?.first?.photo_reference
        }
        
        do {
            // Save changes to Core Data
            try container.viewContext.save()
        } catch {
            // Handle errors during saving
            print("Error saving places to CoreData: \(error)")
        }
    }
}



