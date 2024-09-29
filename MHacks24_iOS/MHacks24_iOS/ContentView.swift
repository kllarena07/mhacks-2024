//
//  ContentView.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isConnected = false
    @State private var showSecondScreen = false
//    var socket = SignalingClient.sharedInstance.getSocket()
    var body: some View {
        NavigationStack {
            VStack {
                Text(isConnected ? "Status: Connected" : "Status: Not Connected")
                    .foregroundColor(isConnected ? .green : .red)
                    .font(.headline)
                    .frame(width: 200, height: 40)
                    .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                    .padding(.vertical)
                    
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 300, height: 300)
                        .overlay(
                            Text("Hold to Connect")
                                .foregroundColor(.white)
                                .font(.title)
                        )
                        .gesture(
                            LongPressGesture(minimumDuration: 1.0)
                                .onEnded { _ in
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                    
                                    isConnected = true
                                    showSecondScreen = true
                                    
                                }
                            
                        )
                }
                Spacer()
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showSecondScreen) {
                LiveFeedView()
            }
        }
    }
}

#Preview {
    ContentView()
}
