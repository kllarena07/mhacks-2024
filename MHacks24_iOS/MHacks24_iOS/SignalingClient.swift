//
//  SignalingClient.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//

//import Foundation
//import WebRTC
//import SocketIO
//
//protocol SignalingClientDelegate: AnyObject {
//    func signalingClientDidReceiveRemoteSDP(_ sdp: RTCSessionDescription)
//    func signalingClientDidReceiveCandidate(_ candidate: RTCIceCandidate)
//}
//
//class SignalingClient: NSObject, ObservableObject {
//    static let sharedInstance = SignalingClient()
//    let manager = SocketManager(socketURL: URL(string: "https://hurry.ngrok.dev")!, config: [.log(true), .compress])
//    var socket: SocketIOClient!
//    
//    override init() {
//        super.init()
//        socket = manager.defaultSocket
//    }
//    
//    func getSocket() -> SocketIOClient {
//        return socket
//    }
//    
//    func establishConnection() {
//        socket.connect()
//    }
//    
//    func closeConnection() {
//        socket.disconnect()
//    }
//    //    private let socket: SocketIOClient!
//    //    weak var delegate: (any SignalingClientDelegate)?
//    //
//    //     init() {
//    //        let manager = SocketManager(socketURL: URL(string: "https://hurry.ngrok.dev/")!, config: [.log(true), .compress])
//    //         socket = manager.defaultSocket
//    //         socket.connect()
//    //           }
//    //
//    //
//    //    func connect() {
//    //        socket.on(clientEvent: .connect) { data, ack in
//    //            print("Socket connected")
//    //        }
//    //
//    func socketOn() {
//        socket.on("answer") { [weak self] data, ack in
//            guard let self = self, let sdpDict = data[0] as? [String: Any] else { return }
//            if let sdp = sdpDict["sdp"] as? String, let type = sdpDict["type"] as? String {
//                let sessionDescription = RTCSessionDescription(type: .answer, sdp: sdp)
//                self.delegate?.signalingClientDidReceiveRemoteSDP(sessionDescription)
//            }
//        }
//        socket.on("offer") { [weak self] data, ack in
//            guard let self = self, let sdpDict = data[0] as? [String: Any] else { return }
//            if let sdp = sdpDict["sdp"] as? String, let type = sdpDict["type"] as? String {
//                let sessionDescription = RTCSessionDescription(type: .offer, sdp: sdp)
//                self.delegate?.signalingClientDidReceiveRemoteSDP(sessionDescription)
//            }
//        }
//        
//        socket.on("ice_candidate") { [weak self] data, ack in
//            guard let self = self, let candidateDict = data[0] as? [String: Any] else { return }
//            if let sdp = candidateDict["candidate"] as? String,
//               let sdpMLineIndex = candidateDict["sdpMLineIndex"] as? Int32,
//               let sdpMid = candidateDict["sdpMid"] as? String {
//                let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
//                self.delegate?.signalingClientDidReceiveCandidate(candidate)
//            }
//        }
//    }
//    
//    //
//    //
//    //        socket.connect()
//    //    }
//    //
//    //    func send(sdp: RTCSessionDescription) {
//    //        let sdpDict: [String: Any] = ["sdp": sdp.sdp, "type": sdp.type.rawValue]
//    //        if sdp.type == .offer {
//    //            socket.emit("offer", sdpDict)
//    //        } else if sdp.type == .answer {
//    //            socket.emit("answer", sdpDict)
//    //        }
//    //    }
//    //
//    //
//    //    func send(candidate: RTCIceCandidate) {
//    //        let candidateDict: [String: Any] = [
//    //            "sdpMLineIndex": candidate.sdpMLineIndex,
//    //            "sdpMid": candidate.sdpMid ?? "",
//    //            "candidate": candidate.sdp
//    //        ]
//    //        socket.emit("ice_candidate", candidateDict)
//    //    }
//    
//    
//}
