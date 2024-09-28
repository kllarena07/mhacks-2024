from flask import Flask
from flask_socketio import SocketIO, emit
import wave
import time
from io import BytesIO

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

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
    print(f'Received audio data: {len(data)} bytes')

    # Create a unique filename based on the current time
    filename = f'audio_snippet_{int(time.time())}.wav'

    # Assuming the audio data is in raw PCM format, you may need to adjust parameters
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(1)  # Mono audio
        wf.setsampwidth(2)  # Sample width in bytes (16-bit audio)
        wf.setframerate(44100)  # Sample rate (44.1 kHz)
        
        # Write the first 5 seconds of audio data
        wf.writeframes(data[:44100 * 2 * 5])  # 44100 samples/sec * 2 bytes/sample * 5 seconds

    print(f'Saved audio snippet to {filename}')

if __name__ == '__main__':
    socketio.run(app, debug=True)