//
//  VideoView.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//
import SwiftUI
import WebRTC
import SocketIO

struct VideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack?
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let view = RTCMTLVideoView()
        view.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        view.videoContentMode = .scaleAspectFill
        return view
    }
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        videoTrack?.add(uiView)
    }
}
