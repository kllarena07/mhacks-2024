"use client";

import { useEffect, useRef } from "react";
import io, { Socket } from "socket.io-client";

const WebRTCComponent = () => {
  const socketRef = useRef<Socket | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);

  const configuration = {
    iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
  };

  useEffect(() => {
    (async () => {
      if (!socketRef.current) {
        socketRef.current = io("https://hurry.ngrok.dev");

        const pc = new RTCPeerConnection(configuration);
        socketRef.current.on("answer", async (answer) => {
          if (answer) {
            const remoteDesc = new RTCSessionDescription(answer);
            await pc.setRemoteDescription(remoteDesc);
          }
        });

        const stream = await navigator.mediaDevices.getUserMedia({
          video: true,
          audio: false,
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

            if (socketRef.current) {
              socketRef.current.emit("answer", answer);
            }
          }
        });

        pc.addEventListener("icecandidate", (event) => {
          if (event.candidate) {
            if (socketRef.current) {
              socketRef.current.emit("ice_candidate", event.candidate);
            }
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

        pc.addEventListener("track", async (event) => {
          console.log("Incoming track:", event);
          const [remoteStream] = event.streams;

          if (videoRef.current) {
            videoRef.current.srcObject = remoteStream;
          }
        });
      }
    })();
    // return () => {
    //   if (localStream) {
    //     localStream.getTracks().forEach((track) => track.stop());
    //   }
    //   if (peerConnection) {
    //     peerConnection.removeEventListener("track", () => {});
    //     peerConnection.close();
    //   }
    //   if (socketRef.current) {
    //     socketRef.current.disconnect();
    //   }
    // };
  }, []);

  return <video ref={videoRef} autoPlay playsInline></video>;
};

export default WebRTCComponent;
