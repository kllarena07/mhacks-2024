
import Foundation
import WebRTC
import SocketIO
import SwiftUI
import Combine

class VideoStream: NSObject, ObservableObject {

    // MARK: - Published Properties
    @Published var localVideoTrack: RTCVideoTrack?
    @Published var remoteVideoTrack: RTCVideoTrack?

    // MARK: - Private Properties
    private var socket: SocketIOClient!
    private var manager: SocketManager!

    private var peerConnectionFactory: RTCPeerConnectionFactory!
    private var peerConnection: RTCPeerConnection!

    private var localAudioTrack: RTCAudioTrack?
    private var videoCapturer: RTCCameraVideoCapturer?

    // Video Views
    private var localRenderer: RTCVideoRenderer?
    private var remoteRenderer: RTCVideoRenderer?
    // binding var for cameraDirection
    private var currentCameraPosition: AVCaptureDevice.Position = .back


    // MARK: - Initialization
    override init() {
        super.init()
        initializeSocket()
        initializeWebRTC()
        startLocalVideoCapture()
    }

    // MARK: - Initialize Socket.IO
    private func initializeSocket() {
        guard let socketURL = URL(string: "https://hurry.ngrok.dev") else {
            print("Invalid Socket URL")
            return
        }

        manager = SocketManager(socketURL: socketURL, config: [.log(true), .compress])
        socket = manager.defaultSocket

        // Define event handlers
        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
            self.createOffer()
        }

        socket.on("offer") { [weak self] data, ack in
            guard let self = self,
                  let sdpDict = data.first as? [String: Any],
                  let sdp = sdpDict["sdp"] as? String,
                  let type = sdpDict["type"] as? String,
                  type == "offer" else { return }
            self.handleRemoteOffer(sdp)
        }

        socket.on("answer") { [weak self] data, ack in
            guard let self = self,
                  let sdpDict = data.first as? [String: Any],
                  let sdp = sdpDict["sdp"] as? String,
                  let type = sdpDict["type"] as? String,
                  type == "answer" else { return }
            self.handleRemoteAnswer(sdp)
        }

        socket.on("ice_candidate") { [weak self] data, ack in
            guard let self = self,
                  let candidateDict = data.first as? [String: Any] else { return }
            self.handleRemoteCandidate(candidateDict)
        }

        socket.connect()
    }

    // MARK: - Initialize WebRTC
    private func initializeWebRTC() {
        // Initialize PeerConnectionFactory
        RTCInitializeSSL()
        peerConnectionFactory = RTCPeerConnectionFactory()

        // Define ICE servers
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        config.sdpSemantics = .unifiedPlan // Use unified plan for SDP

        // Define constraints
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)

        // Initialize PeerConnection
        peerConnection = peerConnectionFactory.peerConnection(with: config, constraints: constraints, delegate: nil)

        // Create and add media tracks
        createMediaSenders()
    }

    private func createMediaSenders() {
        // Video
        let videoSource = peerConnectionFactory.videoSource()
        videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        localVideoTrack = peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")

        // Audio
        let audioSource = peerConnectionFactory.audioSource(with: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil))
        localAudioTrack = peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")

        // Add tracks to peer connection
        if let localVideoTrack = localVideoTrack {
            peerConnection.add(localVideoTrack, streamIds: ["stream0"])
        }
        if let localAudioTrack = localAudioTrack {
            peerConnection.add(localAudioTrack, streamIds: ["stream0"])
        }
    }

    // MARK: - Start Local Video Capture
    private func startLocalVideoCapture() {
        // Request camera access
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                print("Camera access denied")
                return
            }

            DispatchQueue.main.async {
                self.captureLocalVideo()
            }
        }
    }

    private func captureLocalVideo() {
        guard let capturer = self.videoCapturer else { return }

        let devices = RTCCameraVideoCapturer.captureDevices()
        guard let camera = devices.first(where: { $0.position == self.currentCameraPosition }) else {
            print("No front camera found")
            return
        }

        let formats = RTCCameraVideoCapturer.supportedFormats(for: camera)
        guard let format = formats.last else {
            print("No supported formats found")
            return
        }

        let fps = Int(format.videoSupportedFrameRateRanges.first?.maxFrameRate ?? 30)

        capturer.startCapture(with: camera, format: format, fps: fps) { error in
            if let error = error {
                print("Error starting capture: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Handle Offers and Answers
    private func createOffer() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveVideo": "true"],
                                              optionalConstraints: nil)

        peerConnection.offer(for: constraints) { [weak self] sdp, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to create offer: \(error.localizedDescription)")
                return
            }
            guard let sdp = sdp else { return }
            self.peerConnection.setLocalDescription(sdp) { error in
                if let error = error {
                    print("Failed to set local description: \(error.localizedDescription)")
                    return
                }
                // Send the offer through Socket.IO
                let offerDict: [String: Any] = [
                    "type": "offer",
                    "sdp": sdp.sdp,
                ]
                self.socket.emit("offer", offerDict)
            }
        }
    }

    private func handleRemoteOffer(_ sdpString: String) {
        let sdp = RTCSessionDescription(type: .offer, sdp: sdpString)
        peerConnection.setRemoteDescription(sdp) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to set remote description: \(error.localizedDescription)")
                return
            }
            self.createAnswer()
        }
    }

    private func createAnswer() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveVideo": "true"],
                                              optionalConstraints: nil)

        peerConnection.answer(for: constraints) { [weak self] sdp, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to create answer: \(error.localizedDescription)")
                return
            }
            guard let sdp = sdp else { return }
            self.peerConnection.setLocalDescription(sdp) { error in
                if let error = error {
                    print("Failed to set local description: \(error.localizedDescription)")
                    return
                }
                // Send the answer through Socket.IO
                let answerDict: [String: Any] = [
                    "type": "answer",
                    "sdp": sdp.sdp
                ]
                self.socket.emit("answer", answerDict)
            }
        }
    }

    private func handleRemoteAnswer(_ sdpString: String) {
        let sdp = RTCSessionDescription(type: .answer, sdp: sdpString)
        peerConnection.setRemoteDescription(sdp) { error in
            if let error = error {
                print("Failed to set remote description: \(error.localizedDescription)")
            } else {
                print("Remote description set successfully")
            }
        }
    }

    // MARK: - Handle ICE Candidates
    private func handleRemoteCandidate(_ candidateDict: [String: Any]) {
        guard let sdp = candidateDict["candidate"] as? String,
              let sdpMid = candidateDict["sdpMid"] as? String,
              let sdpMLineIndex = candidateDict["sdpMLineIndex"] as? Int32 else {
            print("Invalid ICE candidate data")
            return
        }

        let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
        peerConnection.add(candidate) { error in
            if let error = error {
                print("Failed to add ICE candidate: \(error.localizedDescription)")
            } else {
                print("ICE candidate added successfully")
            }
        }
    }
}

// MARK: - RTCPeerConnectionDelegate
extension VideoStream: RTCPeerConnectionDelegate {

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("Signaling state changed: \(stateChanged.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("Did add stream")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let remoteVideoTrack = stream.videoTracks.first {
                self.remoteVideoTrack = remoteVideoTrack
            }
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("Did remove stream")
        DispatchQueue.main.async { [weak self] in
            self?.remoteVideoTrack = nil
        }
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("Peer connection should negotiate")
        createOffer()
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("ICE connection state changed: \(newState.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("Generated ICE candidate")
        // Send the candidate through Socket.IO
        let candidateDict: [String: Any] = [
            "candidate": candidate.sdp,
            "sdpMid": candidate.sdpMid ?? "",
            "sdpMLineIndex": candidate.sdpMLineIndex
        ]
        socket.emit("ice_candidate", candidateDict)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("Did remove ICE candidates")
        // Handle removed candidates if necessary
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("ICE gathering state changed: \(newState.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("Data channel opened: \(dataChannel.label)")
        // Handle data channel if needed
    }
}

extension VideoStream {
    
    /// Switches the camera between front and back.
    func switchCamera() {
        // Determine the new camera position
        let newPosition: AVCaptureDevice.Position = (self.currentCameraPosition == .front) ? .back : .front
        print("Switching to \(newPosition == .front ? "front" : "back") camera")
        captureLocalVideo(position: newPosition)
    }
    
    /// Captures video from the specified camera position.
    /// - Parameter position: The camera position to capture from (.front or .back).
    private func captureLocalVideo(position: AVCaptureDevice.Position) {
        guard let capturer = self.videoCapturer else {
            print("Video capturer is not initialized.")
            return
        }
        
        let devices = RTCCameraVideoCapturer.captureDevices()
        guard let camera = devices.first(where: { $0.position == position }) else {
            print("No camera found for position: \(position)")
            return
        }
        
        let formats = RTCCameraVideoCapturer.supportedFormats(for: camera)
        guard let format = formats.last else {
            print("No supported formats found for camera: \(position)")
            return
        }
        
        let fps = Int(format.videoSupportedFrameRateRanges.first?.maxFrameRate ?? 30)
        
        // Stop current capture before switching
        capturer.stopCapture { [weak self] in
            // Start capturing with the new camera
            capturer.startCapture(with: camera, format: format, fps: fps) { error in
                if let error = error {
                    print("Error starting capture with \(position == .front ? "front" : "back") camera: \(error.localizedDescription)")
                } else {
                    print("Started video capture with \(position == .front ? "front" : "back") camera, format: \(format)")
                    self?.currentCameraPosition = position
                }
            }
        }
    }
}
