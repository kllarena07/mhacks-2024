"use client";

import { useEffect, useRef, useState } from "react";
import io, { Socket } from "socket.io-client";

const WebRTCComponent = () => {
  const socketRef = useRef<Socket | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const [chatHistory, setChatHistory] = useState<string[]>([]);

  const configuration = {
    iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
  };

  const postMessageAndPlayAudio = async (message: string) => {
    try {
      const response = await fetch("/api/tts/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ message }),
      });

      if (!response.ok) {
        throw new Error("Failed to fetch audio");
      }

      const audioBlob = await response.blob();
      const audioUrl = URL.createObjectURL(audioBlob);
      const audio = new Audio(audioUrl);
      audio.play();
    } catch (error) {
      console.error("Error posting message and playing audio:", error);
    }
  };

  useEffect(() => {
    (async () => {
      if (!socketRef.current) {
        socketRef.current = io("https://hurry.ngrok.dev", {
          withCredentials: true,
          transports: ["websocket", "polling"],
        });
        const pc = new RTCPeerConnection(configuration);
        pc.addEventListener("datachannel", (event) => {
          const dataChannel = event.channel;
          dataChannel.addEventListener("message", async (event) => {
            const { message } = event.data;

            if (message) {
              await postMessageAndPlayAudio(message);
              setChatHistory((prevHistory) => [...prevHistory, message]);
              console.log(chatHistory);
            }
          });
        });
        const streams = await navigator.mediaDevices.getUserMedia({
          video: true,
          audio: true,
        });
        streams.getTracks().forEach((track) => pc.addTrack(track, streams));
        socketRef.current.on("answer", async (answer) => {
          if (answer) {
            const remoteDesc = new RTCSessionDescription(answer);
            await pc.setRemoteDescription(remoteDesc);
          }
        });

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
          const remoteStream = event.streams[0];
          console.log(remoteStream);

          if (videoRef.current) {
            videoRef.current.srcObject = remoteStream;
          }
        });
      }
    })();
  });

  return <video ref={videoRef} autoPlay playsInline></video>;
};

export default WebRTCComponent;
