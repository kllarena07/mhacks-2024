from flask import Flask
from flask_cors import CORS
from flask_socketio import SocketIO, emit
from flask import request

app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

@socketio.on('connect')
def handle_connect():
    t_value = request.args.get('t')
    if t_value:
        print(f'Client connected: {t_value}')

@socketio.on('disconnect')
def handle_disconnect():
    t_value = request.args.get('t')
    if t_value:
        print(f'Client disconnected: {t_value}')

@socketio.on('offer')
def handle_offer(offer):
    print('Received offer:', offer)
    emit('offer', offer, broadcast=True, include_self=False)

@socketio.on('answer')
def handle_answer(answer):
    print('Received answer:', answer)
    emit('answer', answer, broadcast=True, include_self=False)

@socketio.on('ice_candidate')
def handle_ice_candidate(candidate):
    print('Received ICE candidate', candidate)
    emit('ice_candidate', candidate, broadcast=True, include_self=False)

if __name__ == '__main__':
    socketio.run(app, debug=True)