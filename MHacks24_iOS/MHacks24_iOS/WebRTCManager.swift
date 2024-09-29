//
//  WebRTCManager.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//
//import Foundation
//import WebRTC
//import SocketIO
//class WebRTCManager: NSObject, ObservableObject {
//    @Published  var localVideoTrack: RTCVideoTrack?
//    @Published  var remoteVideoTrack: RTCVideoTrack?
//    private var peerConnectionFactory: RTCPeerConnectionFactory!
//    private var peerConnection: RTCPeerConnection?
//    private var localAudioTrack: RTCAudioTrack?
//    private var videoCapturer: RTCCameraVideoCapturer?
//    private var signalingClient: SignalingClient!
//    override init() {
//        super.init()
//        setupWebRTC()
//        setupSignaling()
//    }
//    
//    private func make() {
//        let stream = peerConnectionFactory.mediaStream(withStreamId: "stream0")
//        if let videoTrack = localVideoTrack {
//            stream.addVideoTrack(videoTrack)
//        }
//        peerConnection?.add(stream)
//        if let sdp = peerConnection?.localDescription?.sdp {
//            let session = RTCSessionDescription(type: .answer, sdp: sdp)
//        }
//    }
//    
//    private func setupWebRTC() {
//        let encoderFactory = RTCDefaultVideoEncoderFactory()
//        let decoderFactory = RTCDefaultVideoDecoderFactory()
//        peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: encoderFactory, decoderFactory: decoderFactory)
//        createPeerConnection()
//        startCaptureLocalVideo()
//    }
//    private func createPeerConnection() {
//        let config = RTCConfiguration()
//        config.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
//        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
//        peerConnection = peerConnectionFactory.peerConnection(with: config, constraints: constraints, delegate: self)
//    }
//    private func startCaptureLocalVideo() {
//        let videoSource = peerConnectionFactory.videoSource()
//        videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
//        localVideoTrack = peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")
//        captureVideo()
//    }
//    private func captureVideo() {
//        guard let capturer = videoCapturer else { return }
//        let devices = RTCCameraVideoCapturer.captureDevices()
//        guard let frontCamera = devices.first(where: { $0.position == .front }) else { return }
//        let formats = RTCCameraVideoCapturer.supportedFormats(for: frontCamera)
//        guard let format = formats.last else { return }
//        let fps = format.videoSupportedFrameRateRanges.first?.maxFrameRate ?? 30
//        capturer.startCapture(with: frontCamera, format: format, fps: Int(fps)) { error in
//            if let error = error {
//                print("Error starting capture: \(error.localizedDescription)")
//            } else {
//                print("Capture started")
//            }
//        }
//    }
//    //  Implement signaling and peer connection methods...
//    func connect() {
//        // Add local tracks
//        let stream = peerConnectionFactory.mediaStream(withStreamId: "stream0")
//        if let videoTrack = localVideoTrack {
//            stream.addVideoTrack(videoTrack)
//        }
//        let audioSource = peerConnectionFactory.audioSource(with: nil)
//        localAudioTrack = peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")
//        stream.addAudioTrack(localAudioTrack!)
//        peerConnection?.add(stream)
//        // Do not create an offer here; wait for the offer from the web app
//    }
//    
//    private func setupSignaling() {
//        signalingClient = SignalingClient()
//        signalingClient.delegate = self
//        signalingClient.connect()
//    }
//}
//extension WebRTCManager: RTCPeerConnectionDelegate {
//    // Implement required delegate methods
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
//    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
//        DispatchQueue.main.async {
//            if let remoteVideoTrack = stream.videoTracks.first {
//                self.remoteVideoTrack = remoteVideoTrack
//            }
//        }
//    }
//    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
//    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
//    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
//        // Send candidate via signaling server
//      //  signalingClient.send(candidate: candidate)
//    }
//    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
//    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
//}
//extension WebRTCManager {
//    func signalingClientDidReceiveRemoteSDP(_ sdp: RTCSessionDescription) {
//        peerConnection?.setRemoteDescription(sdp, completionHandler: { [weak self] error in
//            if let error = error {
//                print("Failed to set remote description: \(error.localizedDescription)")
//                return
//            }
//            
//            if sdp.type == .offer {
//                // Create an answer after receiving an offer
//                let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
//                self?.peerConnection?.answer(for: constraints, completionHandler: { answerSDP, error in
//                    guard let answerSDP = answerSDP else { return }
//                    self?.peerConnection?.setLocalDescription(answerSDP, completionHandler: { error in
//                        if let error = error {
//                            print("Failed to set local description: \(error.localizedDescription)")
//                            return
//                        }
//                      //  self?.signalingClient.send(sdp: answerSDP)
//                    })
//                })
//            }
//        })
//    }
//
//    func signalingClientDidReceiveCandidate(_ candidate: RTCIceCandidate) {
//        peerConnection?.add(candidate, completionHandler: { error in
//            if let error = error {
//                print("Failed to add ICE candidate: \(error.localizedDescription)")
//            } else {
//                print("ICE candidate successfully added.")
//            }
//        })
//    }
//
//}
