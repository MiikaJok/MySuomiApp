import XCTest
import CoreData

@testable import MySuomiApp 

class PersistenceControllerTests: XCTestCase {
    
    func testSaveAndFetchPlaces() {
        let persistenceController = PersistenceController(inMemory: true)
        
        // Sample places to save
        let samplePlaces: [Place] = [
            Place(name: "Place1", place_id: "id_1", rating: 4.5, types: ["restaurant"], vicinity: "Location1", opening_hours: OpeningHours(open_now: true), photos: [Photo(photo_reference: "photo_ref_1", width: 100, height: 100)]),
            Place(name: "Place2", place_id: "id_2", rating: 4.0, types: ["cafe"], vicinity: "Location2", opening_hours: OpeningHours(open_now: false), photos: [Photo(photo_reference: "photo_ref_2", width: 120, height: 120)]),
        ]
        
        persistenceController.savePlaces(samplePlaces)
        let fetchedPlaces = persistenceController.fetchPlaces()
        
        // Ensure that the fetched places match the saved places
        XCTAssertEqual(fetchedPlaces.count, samplePlaces.count)
        
        for (index, fetchedPlace) in fetchedPlaces.enumerated() {
            XCTAssertEqual(fetchedPlace.name, samplePlaces[index].name)
        }
    }
    
    func testPrintLikesFromCoreData() {
        let persistenceController = PersistenceController(inMemory: true)
        
        // Sample like to print
        let sampleLike = Like(context: persistenceController.container.viewContext)
        sampleLike.name = "SampleLike"
        sampleLike.image = "sample_photo_ref"
        
        // Save the sample like to Core Data
        persistenceController.save()
        
    }
}

