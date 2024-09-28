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
    @State private var isMuted = false
    @State private var showChat = false
    @State private var isConnected = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text(isConnected ? "Status: Connected" : "Status: Not Connected")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))

            Spacer()
            
            Rectangle()
                .fill(Color.black)
                .frame(height: 300)
                .overlay(
                    Text("Live Video Feed")
                        .foregroundColor(.white)
                        .font(.title)
                )
            Spacer()
            
            HStack {
                Button(action: {
                    isMuted.toggle()
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
                    dismiss()
                }) {
                    Image(systemName: "phone.down.fill")
                        .font(.largeTitle)
                        .padding()
                }
            }
            .padding(.horizontal, 40)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    LiveFeedView()
}
