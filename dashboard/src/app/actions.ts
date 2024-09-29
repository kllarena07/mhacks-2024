"use server";

import { ElevenLabsClient, play } from "elevenlabs";

const ELEVENLABS_API_KEY = process.env.ELEVENLABS_API_KEY;
const elevenlabs = new ElevenLabsClient({
  apiKey: ELEVENLABS_API_KEY,
});

export const generate_audio = async (message: string) => {
  "use server";
  const audio = await elevenlabs.generate({
    voice: "Rachel",
    text: message,
    model_id: "eleven_multilingual_v2",
  });
  play(audio);
};
