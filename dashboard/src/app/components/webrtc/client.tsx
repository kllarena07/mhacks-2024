"use client";

import { useEffect, useRef, useState } from "react";
import io, { Socket } from "socket.io-client";
// import GoogleMap from "../map/map";

const WebRTCComponent = () => {
  const socketRef = useRef<Socket | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  // const [long, setLong] = useState(-83.7376);
  // const [lat, setLat] = useState(42.2783);
  const [chatHistory, setChatHistory] = useState<string[]>([]);

  // setInterval(() => {
  //   setLong((prev) => prev + 0.001);
  //   setLat((prev) => prev + 0.001);
  // }, 1500);

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

        const configuration = {
          iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
        };

        const recv = new RTCPeerConnection(configuration);
        const streams = await navigator.mediaDevices.getUserMedia({
          audio: true,
          video: true,
        });

        streams.getTracks().forEach((track) => {
          recv.addTrack(track, streams);
        });

        recv.addEventListener("track", async (event) => {
          console.log("Incoming track:", event);
          const remoteStream = event.streams[0];
          console.log(remoteStream);

          if (videoRef.current) {
            videoRef.current.srcObject = remoteStream;
          }
        });

        socketRef.current.on("offer", async (offer) => {
          const remoteDesc = new RTCSessionDescription(offer);
          await recv.setRemoteDescription(remoteDesc);

          const answer = await recv.createAnswer();
          await recv.setLocalDescription(answer);

          if (socketRef.current) socketRef.current.emit("answer", answer);
        });

        socketRef.current.on("ice_candidate", (candidate) => {
          if (candidate) {
            recv.addIceCandidate(new RTCIceCandidate(candidate));
          }
        });

        recv.addEventListener("icecandidate", (event) => {
          if (event.candidate && socketRef.current) {
            socketRef.current.emit("ice_candidate", event.candidate);
          }
        });

        recv.addEventListener("connectionstatechange", () => {
          if (recv.connectionState === "connected") {
            console.log("Peers are connected!");
          }
        });
      }
    })();
  });

  return (
    <section>
      <video ref={videoRef} autoPlay playsInline muted></video>
      {/* <GoogleMap longitude={long} latitude={lat} /> */}
    </section>
  );
};

export default WebRTCComponent;
