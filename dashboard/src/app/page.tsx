"use client";

import { useEffect, useRef, useState } from "react";
import io from "socket.io-client";

const WebRTCComponent = () => {
  const [peerConnection, setPeerConnection] = useState(null);
  const [localStream, setLocalStream] = useState(null);
  const socketRef = useRef(null);

  useEffect(() => {
    // Initialize WebSocket connection
    socketRef.current = io("http://127.0.0.1:5000");

    // Set up WebRTC
    const pc = new RTCPeerConnection({
      iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
    });
    setPeerConnection(pc);

    // Get local audio stream
    navigator.mediaDevices
      .getUserMedia({ audio: true })
      .then((stream) => {
        setLocalStream(stream);
        stream.getTracks().forEach((track) => pc.addTrack(track, stream));

        // Set up audio processing
        const audioContext = new AudioContext();
        const sourceNode = audioContext.createMediaStreamSource(stream);
        const processorNode = audioContext.createScriptProcessor(4096, 1, 1);

        processorNode.onaudioprocess = (audioProcessingEvent) => {
          const audioData = audioProcessingEvent.inputBuffer.getChannelData(0);
          socketRef.current.emit("audio_data", Array.from(audioData));
        };

        sourceNode.connect(processorNode);
        processorNode.connect(audioContext.destination);
      })
      .catch((error) => console.error("Error accessing microphone:", error));

    // Handle ICE candidates
    pc.onicecandidate = (event) => {
      if (event.candidate) {
        socketRef.current.emit("ice_candidate", event.candidate);
      }
    };

    // Handle incoming ICE candidates
    socketRef.current.on("ice_candidate", (candidate) => {
      pc.addIceCandidate(new RTCIceCandidate(candidate));
    });

    // Handle offer/answer exchange
    socketRef.current.on("offer", async (offer) => {
      await pc.setRemoteDescription(new RTCSessionDescription(offer));
      const answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      socketRef.current.emit("answer", answer);
    });

    socketRef.current.on("answer", (answer) => {
      pc.setRemoteDescription(new RTCSessionDescription(answer));
    });

    // Clean up
    return () => {
      if (localStream) {
        localStream.getTracks().forEach((track) => track.stop());
      }
      if (peerConnection) {
        peerConnection.close();
      }
      if (socketRef.current) {
        socketRef.current.disconnect();
      }
    };
  }, []);

  const startCall = async () => {
    const offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);
    socketRef.current.emit("offer", offer);
  };

  return (
    <div>
      <h1>WebRTC Audio Transmission</h1>
      <button onClick={startCall}>Start Call</button>
    </div>
  );
};

export default WebRTCComponent;
