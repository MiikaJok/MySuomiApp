import XCTest
import MapKit
import CoreLocation

@testable import MySuomiApp

class LocationManagerTests: XCTestCase {
    
    var locationManager: LocationManager!
    
    override func setUp() {
        super.setUp()
        locationManager = LocationManager()
    }
    
    override func tearDown() {
        locationManager = nil
        super.tearDown()
    }
    
    //Tests for searchPlaces(query:)
    
    func testSearchPlacesWithEmptyQuery() {
        // Given
        let query = ""
        
        // When
        locationManager.searchPlaces(query: query)
        
        // Then
        XCTAssertTrue(locationManager.suggestions.isEmpty, "Suggestions should be empty for an empty query")
    }
    
    func testSearchPlacesWithNonEmptyQuery() {
        // Given
        let query = "Helsinki"
        
        // When
        locationManager.searchPlaces(query: query)
        
        // Then
        XCTAssertFalse(locationManager.suggestions.isEmpty, "Suggestions should not be empty for a non-empty query")
    }
    
    //Tests for handleSuggestionSelection(_:)
    
    func testHandleSuggestionSelection() {
        // Given
        let suggestion = MKLocalSearchCompletion()
        
        // When
        locationManager.handleSuggestionSelection(suggestion)
        
        // Then
        XCTAssertNotNil(locationManager.errorMessage, "Error message should be set if handling suggestion selection fails")
    }
    
    //Tests for completerDidUpdateResults(_:)
    
    func testCompleterDidUpdateResults() {
        // Given
        let completer = MKLocalSearchCompleter()
        completer.delegate = locationManager
        
        // When
        locationManager.completerDidUpdateResults(completer)
        
        // Then
        XCTAssertTrue(!locationManager.suggestions.isEmpty, "Suggestions should be updated when completer updates results")
    }
    
    //Tests for completer(_:didFailWithError:)
    
    func testCompleterDidFailWithError() {
        // Given
        let completer = MKLocalSearchCompleter()
        completer.delegate = locationManager
        let error = NSError(domain: "testDomain", code: 123, userInfo: nil)
        
        // When
        locationManager.completer(completer, didFailWithError: error)
        
        // Then
        XCTAssertNotNil(locationManager.errorMessage, "Error message should be set when completer fails with an error")
    }
}
