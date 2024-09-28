from flask import Flask
from flask_socketio import SocketIO, emit
import wave
import numpy as np
import struct

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

collected_audio = []
SAMPLE_RATE = 44100
DURATION = 5  # seconds

@socketio.on('connect')
def handle_connect():
    print('Client connected')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

@socketio.on('offer')
def handle_offer(offer):
    print('Received offer')
    emit('offer', offer, broadcast=True, include_self=False)

@socketio.on('answer')
def handle_answer(answer):
    print('Received answer')
    emit('answer', answer, broadcast=True, include_self=False)

@socketio.on('ice_candidate')
def handle_ice_candidate(candidate):
    print('Received ICE candidate')
    emit('ice_candidate', candidate, broadcast=True, include_self=False)

@socketio.on('audio_data')
def handle_audio_data(data):
    global collected_audio
    # Convert the incoming data to 16-bit PCM
    pcm_data = [int(sample * 32767) for sample in data]
    collected_audio.extend(pcm_data)
    print(f'Received audio data: {len(data)} samples. Total collected: {len(collected_audio)}')
    
    if len(collected_audio) >= SAMPLE_RATE * DURATION:
        write_to_file(collected_audio)
        collected_audio = []

def write_to_file(audio_data):
    with wave.open('output.wav', 'wb') as wf:
        wf.setnchannels(1)  # Mono audio
        wf.setsampwidth(2)  # 2 bytes for 16-bit audio
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(struct.pack(f'{len(audio_data)}h', *audio_data))
    print('Audio data written to output.wav')

if __name__ == '__main__':
    socketio.run(app, debug=True)