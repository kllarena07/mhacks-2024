//
//  ChatView.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//

import SwiftUI
import Speech
import AVFoundation

// Define a Message struct to hold original and translated texts
struct Message: Identifiable {
    let id = UUID()
    let original: String
    var translated: String?
}

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isTranscribing = false
    @State private var targetLanguage = "en"
    @State private var translationService = TranslationService()
    
    var body: some View {
        VStack {
            // Messages List
            List {
                ForEach(messages) { message in
                    VStack(alignment: .leading, spacing: 8) {
                        // Original Message
                        Text("Original: \(message.original)")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        
                        // Translated Message
                        if let translated = message.translated {
                            Text("Translated: \(translated)")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            // Show a placeholder while translation is in progress
                            Text("Translating...")
                                .padding()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
            
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
                    .frame(minHeight: 30)
                
                // Send Button
                Button(action: sendMessage) {
                    Text("Send")
                        .bold()
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // Create a new message with the original text and no translation yet
        var newMessage = Message(original: trimmedMessage, translated: nil)
        messages.append(newMessage)
        messageText = ""
        
        // Find the index of the newly added message
        guard let index = messages.firstIndex(where: { $0.id == newMessage.id }) else { return }
        
        // Initiate translation
        translationService.translate(text: newMessage.original, toLanguage: targetLanguage) { result in
            switch result {
            case .success(let translatedText):
                DispatchQueue.main.async {
                    messages[index].translated = translatedText
                }
            case .failure(let error):
                print("Translation error: \(error.localizedDescription)")
                // Optionally, you can set an error message or retry logic here
            }
        }
    }
}


#Preview {
    ChatView()
}
