
import XCTest
@testable import MySuomiApp

class FetchPlacesTests: XCTestCase {
    
    // Test fetching places for an invalid type
    func testFetchPlacesForInvalidType() {
        let expectation = expectation(description: "Fetching places")
        
        fetchPlaces(for: ["invalid_type"]) { places in
            XCTAssertNotNil(places)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    // Test fetching places with an empty type array
    func testFetchPlacesForEmptyTypeArray() {
        let expectation = expectation(description: "Fetching places")
        
        fetchPlaces(for: []) { places in
            XCTAssertNil(places)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    // Test fetching places with a negative radius
    func testFetchPlacesWithNegativeRadius() {
        let expectation = expectation(description: "Fetching places")
        
        fetchPlaces(for: ["restaurant"], radius: -500) { places in
            XCTAssertNil(places)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    // Test fetching places with a large radius
    func testFetchPlacesWithLargeRadius() {
        let expectation = expectation(description: "Fetching places")
        
        fetchPlaces(for: ["restaurant"], radius: 100000) { places in
            XCTAssertNotNil(places)
            XCTAssertGreaterThan(places?.count ?? 0, 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}

