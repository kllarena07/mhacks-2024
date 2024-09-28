"use client";

import { useEffect, useRef, useState } from "react";
import io from "socket.io-client";

const WebRTCComponent = () => {
  // const [peerConnection, setPeerConnection] = useState(null);
  // const [localStream, setLocalStream] = useState(null);
  const socketRef = useRef<ReturnType<typeof io> | null>(null);

  const configuration = {
    iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
  };

  useEffect(() => {
    (async () => {
      if (!socketRef.current) {
        socketRef.current = io("http://127.0.0.1:5000");

        const pc = new RTCPeerConnection(configuration);
        socketRef.current.on("answer", async (answer) => {
          if (answer) {
            const remoteDesc = new RTCSessionDescription(answer);
            await pc.setRemoteDescription(remoteDesc);
          }
        });

        const stream = await navigator.mediaDevices.getUserMedia({
          audio: true,
        });
        stream.getTracks().forEach((track) => pc.addTrack(track, stream));

        const offer = await pc.createOffer();
        await pc.setLocalDescription(offer);

        socketRef.current.emit("offer", offer);

        socketRef.current.on("offer", async (offer) => {
          if (offer) {
            pc.setRemoteDescription(new RTCSessionDescription(offer));

            const answer = await pc.createAnswer();
            await pc.setLocalDescription(answer);

            socketRef.current.emit("answer", answer);
          }
        });

        pc.addEventListener("icecandidate", (event) => {
          if (event.candidate) {
            socketRef.current.emit("ice_candidate", event.candidate);
          }
        });

        socketRef.current.on("ice_candidate", async (candidate) => {
          if (candidate) {
            try {
              await pc.addIceCandidate(candidate);
            } catch (e) {
              console.error("Error adding received ice candidate", e);
            }
          }
        });

        pc.addEventListener("connectionstatechange", () => {
          if (pc.connectionState === "connected") {
            console.log("Peers are connected!");
          }
        });
      }
    })();
  }, []);
  // Set up WebRTC
  //   const pc = new RTCPeerConnection({
  //     iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
  //   });
  //   setPeerConnection(pc);

  //   // Get local audio stream
  //   navigator.mediaDevices
  //     .getUserMedia({ audio: true })
  //     .then((stream) => {
  //       setLocalStream(stream);
  //       stream.getTracks().forEach((track) => pc.addTrack(track, stream));

  //       startCall(pc);
  //     })
  //     .catch((error) => console.error("Error accessing microphone:", error));

  //   // Handle ICE candidates
  //   pc.onicecandidate = (event) => {
  //     if (event.candidate) {
  //       socketRef.current.emit("ice_candidate", event.candidate);
  //     }
  //   };

  //   // Handle incoming ICE candidates
  //   socketRef.current.on("ice_candidate", (candidate) => {
  //     pc.addIceCandidate(new RTCIceCandidate(candidate));
  //   });

  //   // Handle offer/answer exchange
  //   socketRef.current.on("offer", async (offer) => {
  //     await pc.setRemoteDescription(new RTCSessionDescription(offer));
  //     const answer = await pc.createAnswer();
  //     await pc.setLocalDescription(answer);
  //     socketRef.current.emit("answer", answer);
  //   });

  //   socketRef.current.on("answer", (answer) => {
  //     pc.setRemoteDescription(new RTCSessionDescription(answer));
  //   });

  //   // Clean up
  //   return () => {
  //     if (localStream) {
  //       localStream.getTracks().forEach((track) => track.stop());
  //     }
  //     if (peerConnection) {
  //       peerConnection.close();
  //     }
  //     if (socketRef.current) {
  //       socketRef.current.disconnect();
  //     }
  //   };
  // }, []);

  // const startCall = async (pc) => {
  //   try {
  //     const offer = await pc.createOffer();
  //     await pc.setLocalDescription(offer);
  //     socketRef.current.emit("offer", offer);
  //     console.log("Call started automatically");
  //   } catch (error) {
  //     console.error("Error starting call:", error);
  //   }
  // };

  return (
    <div>
      <h1>WebRTC Audio Transmission</h1>
      <p>Call starts automatically when the page loads.</p>
    </div>
  );
};

export default WebRTCComponent;
