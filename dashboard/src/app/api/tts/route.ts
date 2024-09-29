import { ElevenLabsClient } from "elevenlabs";

const ELEVENLABS_API_KEY = process.env.ELEVENLABS_API_KEY;

const client = new ElevenLabsClient({
  apiKey: ELEVENLABS_API_KEY,
});

const createAudioStreamFromText = async (text: string): Promise<Buffer> => {
  const audioStream = await client.generate({
    voice: "Rachel",
    model_id: "eleven_turbo_v2_5",
    text,
  });

  const chunks: Buffer[] = [];
  for await (const chunk of audioStream) {
    chunks.push(chunk);
  }

  const content = Buffer.concat(chunks);
  return content;
};

export async function POST(request: Request) {
  try {
    const { message } = await request.json();
    const audioContent = await createAudioStreamFromText(message);
    return new Response(audioContent, {
      status: 200,
      headers: {
        "Content-Type": "audio/mpeg",
      },
    });
  } catch (error) {
    return new Response(`Webhook error: ${(error as Error).message}`, {
      status: 400,
    });
  }
}
