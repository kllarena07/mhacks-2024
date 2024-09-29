
//
//  LiveFeed.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//
import SwiftUI
import Speech
import AVFoundation
struct LiveFeedView: View {
    @State  private var isMuted = false
    @State  private var showChat = false
    @State  private var isConnected = false
    @State  private var translatedTexts: [String] = []
    @Environment(\.dismiss) var dismiss
    @StateObject  private var webRTCManager = WebRTCManager()
    @StateObject  private var speechRecognizer = SpeechRecognizer()
    @StateObject  private var translationService = TranslationService()
    @State  private var sourceLanguage = "en"
    @State  private var targetLanguage = "es" // Change this to your desired target language
    
    var body: some View {
        
        VStack {
            Text(isConnected ? "Status: Connected" : "Status: Not Connected")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
            
            Spacer()
            
            if let remoteVideoTrack = webRTCManager.remoteVideoTrack {
                VideoView(videoTrack: remoteVideoTrack)
                    .ignoresSafeArea()
            }
            
            if let localVideoTrack = webRTCManager.localVideoTrack {
                VideoView(videoTrack: localVideoTrack)
                    .frame(width: 150, height: 200)
                    .cornerRadius(8)
                    .padding()
            }
            
            // Display translated texts
            //            ScrollViewReader { proxy in
            //                ScrollView {
            //                    VStack(alignment: .leading, spacing: 10) {
            //                        ForEach(translatedTexts.indices, id: \.self) { index in
            //                            Text(translatedTexts[index])
            //                                .padding(.vertical, 2)
            //                                .id(index)
            //                        }
            //                    }
            ////                    .onChange(of: translatedTexts) { _ in
            ////                        if let lastIndex = translatedTexts.indices.last {
            ////                            proxy.scrollTo(lastIndex, anchor: .bottom)
            ////                        }
            ////                    }
            //                }
            //            }
            //            .frame(height: 100)
            //            .background(Color.gray.opacity(0.1))
            //            .cornerRadius(8)
            //            .padding()
            
            if !speechRecognizer.transcribedText.isEmpty {
                
                Text("Transcribed: \(speechRecognizer.transcribedText)")
                    .padding()
                    .foregroundColor(.gray)
            }
            
            // Display current transcription
            VStack(alignment: .leading) {
                Text("Original: \(speechRecognizer.transcribedText)")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Text("Translated: \(translatedTexts.last ?? "")")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            HStack {
                Picker("Source", selection: $sourceLanguage) {
                    Text("English").tag("en")
                    Text("Spanish").tag("es")
                    // Add more languages as needed
                }
                .pickerStyle(MenuPickerStyle())
                
                Picker("Target", selection: $targetLanguage) {
                    Text("English").tag("en")
                    Text("Spanish").tag("es")
                    // Add more languages as needed
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding()
            
            Spacer()
            
            HStack {
                Button(action: {
                    isMuted.toggle()
                    if isMuted {
                        speechRecognizer.stopTranscribing()
                    } else if webRTCManager.remoteVideoTrack != nil {
                        speechRecognizer.startTranscribing()
                    }
                }) {
                    Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.largeTitle)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    showChat = true
                }) {
                    Image(systemName: "message.fill")
                        .font(.largeTitle)
                        .padding()
                }
                .sheet(isPresented: $showChat) {
                    ChatView()
                }
                
                Spacer()
                
                Button(action: {
                    isConnected = false
                    speechRecognizer.stopTranscribing()
                    dismiss()
                }) {
                    Image(systemName: "phone.down.fill")
                        .font(.largeTitle)
                        .padding()
                }
            }
            .padding(.horizontal, 40)
        }
        .onReceive(speechRecognizer.$transcribedText) { newText in
            if !newText.isEmpty && (translatedTexts.last != newText) {
                translationService.translate(text: newText, toLanguage: targetLanguage) { result in
                    switch result {
                    case .success(let translatedText):
                        DispatchQueue.main.async {
                            self.translatedTexts.append(translatedText)
                            // Optionally, limit the number of stored texts to prevent excessive memory usage
                            if self.translatedTexts.count > 50 {
                                self.translatedTexts.removeFirst()
                            }
                        }
                    case .failure(let error):
                        print("Translation error: \(error.localizedDescription)")
                    }
                }
            }
        }
        .onAppear {
            // Start Speech Recognition when the view appears
            speechRecognizer.startTranscribing()
        }
        .onDisappear {
            // Stop Speech Recognition when the view disappears
            speechRecognizer.stopTranscribing()
        }
    }
}

#Preview  {
    LiveFeedView()
}
