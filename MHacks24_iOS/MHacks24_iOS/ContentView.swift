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
    var body: some View {
        NavigationStack {
            VStack {
                Text(isConnected ? "Status: Connected" : "Status: Not Connected")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 200, height: 200)
                        .overlay(
                            Text("Hold to Connect")
                                .foregroundColor(.white)
                                .font(.title)
                        )
                        .gesture(
                            LongPressGesture(minimumDuration: 3.0)
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
