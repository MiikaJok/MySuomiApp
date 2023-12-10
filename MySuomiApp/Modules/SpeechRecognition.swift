import Foundation
import Speech
import AVFoundation

// ObservableObject class responsible for handling speech recognition functionality
class SpeechRecognition: ObservableObject {
    
    // Published property to store the recognized text
    @Published var recognizedText: String = ""
    
    // Published property to track the recording state
    @Published var isRecording: Bool = false
    
    // Audio processing engine for capturing and processing audio
    private let audioEngine = AVAudioEngine()
    
    // Speech recognizer instance for handling speech recognition
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    
    // Request to recognize speech from audio buffers
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    // Task performed based on the provided recognition request
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Function to start recording speech
    func startRecording() {
        // Check if recording is not already in progress
        guard !isRecording else { return }
        resetAudioEngine()
        
        // Request microphone permissions
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                // Configure audio session for recording
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                    
                    // Set up input node for audio engine
                    let inputNode = self.audioEngine.inputNode
                    let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                    self.recognitionRequest = recognitionRequest
                    
                    // Set up the recognition task to handle the result or error of speech recognition
                    self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                        var isFinal = false
                        
                        if let result = result {
                            // Update recognizedText with the formatted transcription result
                            DispatchQueue.main.async {
                                self.recognizedText = result.bestTranscription.formattedString
                            }
                            isFinal = result.isFinal
                        }
                        
                        // Check for errors or if the recognition is final, then stop recording
                        if error != nil || isFinal {
                            self.stopRecording()
                        }
                    }
                    
                    // Set up audio processing node to capture and append audio buffers to the recognition request
                    let recordingFormat = inputNode.outputFormat(forBus: 0)
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                        self.recognitionRequest?.append(buffer)
                    }
                    
                    // Start the audio engine for recording on the main thread
                    DispatchQueue.main.async {
                        do {
                            try self.audioEngine.start()
                            self.isRecording = true
                        } catch {
                            // Handle any errors that occur during setup
                            print("Error starting recording: \(error.localizedDescription)")
                        }
                    }
                } catch {
                    print("Error starting recording: \(error.localizedDescription)")
                }
            } else {
                print("Microphone permissions denied")
            }
        }
    }
    
    // Function to stop recording speech
    func stopRecording() {
        if audioEngine.isRunning {
            // Stop the audio engine, end audio recognition request, and reset variables
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionRequest = nil
            recognitionTask?.cancel()
            recognitionTask = nil
            isRecording = false
        }
    }
    //makes sure everything is reseted to be able to start a new clear speech recognition session
    func resetAudioEngine() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

