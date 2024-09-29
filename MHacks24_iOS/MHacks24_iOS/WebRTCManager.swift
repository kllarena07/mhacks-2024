//
//  WebRTCManager.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//
import Foundation
import WebRTC
class WebRTCManager: NSObject, ObservableObject {
    @Published  var localVideoTrack: RTCVideoTrack?
    @Published  var remoteVideoTrack: RTCVideoTrack?
    private var peerConnectionFactory: RTCPeerConnectionFactory!
    private var peerConnection: RTCPeerConnection?
    private var localAudioTrack: RTCAudioTrack?
    private var videoCapturer: RTCCameraVideoCapturer?
    private var signalingClient: SignalingClient!
    override init() {
        super.init()
        setupWebRTC()
        setupSignaling()
    }
    private func setupWebRTC() {
        let encoderFactory = RTCDefaultVideoEncoderFactory()
        let decoderFactory = RTCDefaultVideoDecoderFactory()
        peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: encoderFactory, decoderFactory: decoderFactory)
        createPeerConnection()
        startCaptureLocalVideo()
    }
    private func createPeerConnection() {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: ["stun:http://stun.l.google.com:19302"])]
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peerConnection = peerConnectionFactory.peerConnection(with: config, constraints: constraints, delegate: self)
    }
    private func startCaptureLocalVideo() {
        let videoSource = peerConnectionFactory.videoSource()
        videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        localVideoTrack = peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")
        captureVideo()
    }
    private func captureVideo() {
        guard let capturer = videoCapturer else { return }
        let devices = RTCCameraVideoCapturer.captureDevices()
        guard let frontCamera = devices.first(where: { $0.position == .front }) else { return }
        let formats = RTCCameraVideoCapturer.supportedFormats(for: frontCamera)
        guard let format = formats.last else { return }
        let fps = format.videoSupportedFrameRateRanges.first?.maxFrameRate ?? 30
        capturer.startCapture(with: frontCamera, format: format, fps: Int(fps)) { error in
            if let error = error {
                print("Error starting capture: \(error.localizedDescription)")
            } else {
                print("Capture started")
            }
        }
    }
    // Implement signaling and peer connection methods...
    func connect() {
        // Add local tracks
        let stream = peerConnectionFactory.mediaStream(withStreamId: "stream0")
        if let videoTrack = localVideoTrack {
            stream.addVideoTrack(videoTrack)
        }
        let audioSource = peerConnectionFactory.audioSource(with: nil)
        localAudioTrack = peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")
        stream.addAudioTrack(localAudioTrack!)
        peerConnection?.add(stream)
        // Create offer
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peerConnection?.offer(for: constraints, completionHandler: { [weak self] sdp, error in
            guard let self = self, let sdp = sdp else { return }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { error in
                // Send offer via signaling server
                self.signalingClient.send(sdp: sdp)
            })
        })
    }
    // Handle incoming SDP and ICE candidates...
    private func setupSignaling() {
        signalingClient = SignalingClient()
        signalingClient.delegate = self
        signalingClient.connect()
    }
}
extension WebRTCManager: RTCPeerConnectionDelegate {
    // Implement required delegate methods
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        DispatchQueue.main.async {
            if let remoteVideoTrack = stream.videoTracks.first {
                self.remoteVideoTrack = remoteVideoTrack
            }
        }
    }
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        // Send candidate via signaling server
        signalingClient.send(candidate: candidate)
    }
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}
extension WebRTCManager: SignalingClientDelegate {
    func signalingClientDidReceiveRemoteSDP(_ sdp: RTCSessionDescription) {
        peerConnection?.setRemoteDescription(sdp, completionHandler: { error in
            if let error = error {
                print("Failed to set remote description: \(error.localizedDescription)")
                return
            }
            // Answer was received, no need to create an answer
        })
    }
    func signalingClientDidReceiveCandidate(_ candidate: RTCIceCandidate) {
        peerConnection?.add(candidate)
    }
}
