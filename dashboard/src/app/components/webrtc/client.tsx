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
  useEffect(() => {
    console.log("WebRTCComponent mounted");
    return () => {
      console.log("WebRTCComponent unmounted");
      if (socketRef.current) {
        socketRef.current.disconnect();
        console.log("Socket disconnected");
      }
    };
  }, []);

  useEffect(() => {
    console.log("Initializing WebRTC connection");
    (async () => {
      if (!socketRef.current) {
        console.log("Connecting to socket...");
        socketRef.current = io("https://hurry.ngrok.dev", {
          withCredentials: true,
          transports: ["websocket", "polling"],
        });

        const pc = new RTCPeerConnection(configuration);
        console.log("RTCPeerConnection created");

        pc.addEventListener("datachannel", (event) => {
          console.log("Data channel event:", event);
          const dataChannel = event.channel;
          dataChannel.addEventListener("message", async (event) => {
            console.log("Data channel message received:", event.data);
            const { message } = event.data;

            if (message) {
              await postMessageAndPlayAudio(message);
              setChatHistory((prevHistory) => [...prevHistory, message]);
              console.log("Updated chat history:", chatHistory);
            }
          });
        });

        const streams = await navigator.mediaDevices.getUserMedia({
          video: true,
          audio: true,
        });
        console.log("User media streams obtained");

        streams.getTracks().forEach((track) => {
          pc.addTrack(track, streams);
          console.log("Track added to RTCPeerConnection:", track);
        });

        socketRef.current.on("answer", async (answer) => {
          console.log("Received answer:", answer);
          if (answer) {
            const newAnswer = answer.sdp.replace(/m=audio.*?\r\n/g, "");
            console.log("Removing audio from SDP:", newAnswer);

            const remoteDesc = new RTCSessionDescription(newAnswer);

            try {
              await pc.setRemoteDescription(remoteDesc);
              console.log("Remote description set with modified answer.");
            } catch (e) {
              console.error("Error setting remote description:", e);
            }
          }
        });

        const offer = await pc.createOffer();
        await pc.setLocalDescription(offer);
        console.log("Offer created and set as local description");

        socketRef.current.emit("offer", offer);
        console.log("Offer emitted to socket");

        socketRef.current.on("offer", async (offer) => {
          console.log("Received offer:", offer);
          if (offer) {
            pc.setRemoteDescription(new RTCSessionDescription(offer));
            console.log("Remote description set with offer");

            const answer = await pc.createAnswer();
            await pc.setLocalDescription(answer);
            console.log("Answer created and set as local description");

            if (socketRef.current) {
              socketRef.current.emit("answer", answer);
              console.log("Answer emitted to socket");
            }
          }
        });

        pc.addEventListener("icecandidate", (event) => {
          console.log("ICE candidate event:", event);
          if (event.candidate) {
            if (socketRef.current) {
              socketRef.current.emit("ice_candidate", event.candidate);
              console.log("ICE candidate emitted to socket");
            }
          }
        });

        socketRef.current.on("ice_candidate", async (candidate) => {
          console.log("Received ICE candidate:", candidate);
          if (candidate) {
            try {
              await pc.addIceCandidate(candidate);
              console.log("ICE candidate added");
            } catch (e) {
              console.error("Error adding received ice candidate", e);
            }
          }
        });

        pc.addEventListener("connectionstatechange", () => {
          console.log("Connection state change:", pc.connectionState);
          if (pc.connectionState === "connected") {
            console.log("Peers are connected!");
          }
        });

        pc.addEventListener("track", async (event) => {
          console.log("Incoming track event:", event);
          const remoteStream = event.streams[0];
          console.log("Remote stream obtained:", remoteStream);

          if (videoRef.current) {
            videoRef.current.srcObject = remoteStream;
            console.log("Remote stream set to video element");
          }
        });
      }
    })();
  });

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

  return (
    <section>
      <video ref={videoRef} autoPlay playsInline></video>
      {/* <GoogleMap longitude={long} latitude={lat} /> */}
    </section>
  );
};

export default WebRTCComponent;
