import XCTest
import Speech
import AVFoundation

@testable import MySuomiApp

class SpeechRecognitionTests: XCTestCase {

    var speechRecognition: SpeechRecognition!

    override func setUp() {
        super.setUp()
        speechRecognition = SpeechRecognition()
    }

    override func tearDown() {
        speechRecognition = nil
        super.tearDown()
    }

    func testStartRecording() {
        let expectation = XCTestExpectation(description: "Recording started")

        speechRecognition.speechRecognizer?.delegate = self

        speechRecognition.startRecording()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertTrue(self.speechRecognition.isRecording)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testStopRecording() {
        let expectation = XCTestExpectation(description: "Recording stopped")

        speechRecognition.speechRecognizer?.delegate = self

        speechRecognition.startRecording()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertTrue(self.speechRecognition.isRecording)

            self.speechRecognition.stopRecording()

            XCTAssertFalse(self.speechRecognition.isRecording)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}

extension SpeechRecognitionTests: SFSpeechRecognizerDelegate {
}
