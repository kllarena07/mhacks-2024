from flask import Flask
from flask_socketio import SocketIO, emit
import wave
import numpy as np

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

# Global variable to store audio data
collected_audio = []

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
    collected_audio.extend(data)  # Collect incoming audio data
    print(f'Received audio data: {len(data)} bytes. Total collected: {len(collected_audio)}')
    
    if len(collected_audio) >= 220500:  # 44100 * 5 for 5 seconds of audio
        write_to_file(collected_audio)
        collected_audio = []  # Clear collected data after writing

def write_to_file(audio_data):
    # Convert the audio data to a bytes object
    audio_bytes = np.array(audio_data, dtype=np.float32).tobytes()  # Assuming float32 in the audio data
    with wave.open('output.wav', 'wb') as wf:
        wf.setnchannels(1)  # Mono audio
        wf.setsampwidth(4)  # 4 bytes for float32
        wf.setframerate(44100)  # Sample rate
        wf.writeframes(audio_bytes)
        print('Audio data written to output.wav')

if __name__ == '__main__':
    socketio.run(app, debug=True)