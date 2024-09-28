//
//  ChatView.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//

import SwiftUI
import Speech
import AVFoundation

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [String] = []
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isTranscribing = false
    var body: some View {
        VStack {
            // Messages List
            List(messages, id: \.self) { message in
                HStack {
                    Text(message)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    Spacer()
                }
            }
            
            // Live Transcription Text (Optional)
            if isTranscribing && !speechRecognizer.transcribedText.isEmpty {
                Text("Transcribed: \(speechRecognizer.transcribedText)")
                    .padding()
                    .foregroundColor(.gray)
            }
            
            // Message Input Field and Buttons
            HStack {
                TextField("Type your message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Speech-to-Text Button
                Button(action: {
                    if isTranscribing {
                        // Stop Transcribing
                        speechRecognizer.stopTranscribing()
                        messageText = speechRecognizer.transcribedText
                        isTranscribing = false
                    } else {
                        // Start Transcribing
                        speechRecognizer.startTranscribing()
                        isTranscribing = true
                    }
                }) {
                    Image(systemName: isTranscribing ? "mic.fill" : "mic")
                        .font(.title)
                }
                .padding(.horizontal, 5)
                
                // Send Button
                Button(action: sendMessage) {
                    Text("Send")
                }
            }
            .padding()
        }
        .onDisappear {
            if isTranscribing {
                speechRecognizer.stopTranscribing()
            }
        }
    }
    
    // Send Message Function
    private func sendMessage() {
        if !messageText.isEmpty {
            messages.append(messageText)
            messageText = ""
        }
    }
}

#Preview {
    ChatView()
}
