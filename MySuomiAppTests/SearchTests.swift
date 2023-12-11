import XCTest

@testable import MySuomiApp

class SearchTests: XCTestCase {
    
    // Test case for fetching places using default place types
    func testFetchPlaces() {
        // Create an expectation for the asynchronous call
        let expectation = XCTestExpectation(description: "Fetching places")
        
        // Call the fetchPlaces function with default place types
        Search.fetchPlaces(for: Search.defaultPlaceTypes) { places in
            // Ensure that the fetched places are not nil
            XCTAssertNotNil(places, "Places should not be nil")
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled or timeout after 5 seconds
        wait(for: [expectation], timeout: 5.0)
    }
    
    // Test case for searching places based on a query string
    func testSearchPlaces() {
        // Create an expectation for the asynchronous call
        let expectation = XCTestExpectation(description: "Searching places")
        
        // Call the searchPlaces function with a sample query
        Search.searchPlaces(query: "restaurant") { places in
            XCTAssertNotNil(places, "Places should not be nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
