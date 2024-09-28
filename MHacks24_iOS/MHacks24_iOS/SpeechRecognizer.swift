//
//  SpeechRecognizer.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: NSObject, ObservableObject {
    @Published var transcribedText: String = ""
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    
    override init() {
        super.init()
        requestAuthorization()
    }
    
    // Request Authorization
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition authorization denied")
                case .restricted:
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    print("Speech recognition not determined")
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    }
    
    // Start Transcription
    func startTranscribing() {
        // Ensure previous tasks are canceled
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session properties weren't set because of an error.")
        }
        
        // Configure recognition request
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = request else {
            fatalError("Unable to create a recognition request")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start the audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine couldn't start because of an error.")
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopTranscribing()
            }
        }
    }
    
    // Stop Transcription
    func stopTranscribing() {
        audioEngine.stop()
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

