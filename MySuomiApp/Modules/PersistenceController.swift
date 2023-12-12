import CoreData

//for managing Core Data persistence
struct PersistenceController {
    // Shared instance accessible across the application
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Initialize the persistent container with the model name
        container = NSPersistentContainer(name: "FavoritesModel")
        
        // Configure for in-memory storage if specified
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(string: "/dev/null")
        }
        
        // Load persistent stores and handle errors
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    // Save changes to the managed object context
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("error: \(error)")
            }
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

