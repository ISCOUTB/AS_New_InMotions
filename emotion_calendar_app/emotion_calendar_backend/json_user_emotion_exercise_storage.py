import json
from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

# File paths for JSON storage
USERS_FILE = 'users.json'
EMOTIONS_FILE = 'emotions.json'
EXERCISES_FILE = 'exercises.json'

def load_json(file_path):
    try:
        with open(file_path, 'r') as file:
            return json.load(file)
    except FileNotFoundError:
        return []

def save_json(file_path, data):
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=2)

@app.route('/register', methods=['POST'])
def register_user():
    data = request.json
    users = load_json(USERS_FILE)
    
    if any(user['email'] == data['email'] for user in users):
        return jsonify({"message": "Usuario ya existe"}), 400
    
    new_user = {
        "name": data['name'],
        "email": data['email'],
        "password": data['password']  # Nota: En una aplicación real, se debe cifrar la contraseña
    }
    users.append(new_user)
    save_json(USERS_FILE, users)
    return jsonify({"message": "Usuario registrado exitosamente"}), 201

@app.route('/login', methods=['POST'])
def login_user():
    data = request.json
    users = load_json(USERS_FILE)
    
    user = next((user for user in users if user['email'] == data['email'] and user['password'] == data['password']), None)
    if user:
        return jsonify({"message": "Login exitoso", "email": user['email']}), 200
    return jsonify({"message": "Credenciales inválidas"}), 401

@app.route('/user/<email>', methods=['GET', 'PUT', 'DELETE'])
def user_operations(email):
    users = load_json(USERS_FILE)
    user = next((user for user in users if user['email'] == email), None)
    
    if not user:
        return jsonify({"message": "Usuario no encontrado"}), 404
    
    if request.method == 'GET':
        return jsonify({"name": user['name'], "email": user['email']}), 200
    elif request.method == 'PUT':
        data = request.json
        user['name'] = data.get('name', user['name'])
        if 'password' in data:
            user['password'] = data['password']
        save_json(USERS_FILE, users)
        return jsonify({"message": "Usuario actualizado exitosamente"}), 200
    elif request.method == 'DELETE':
        users = [u for u in users if u['email'] != email]
        save_json(USERS_FILE, users)
        return jsonify({"message": "Usuario eliminado exitosamente"}), 200

@app.route('/emotion', methods=['POST'])
def save_emotion():
    data = request.json
    emotions = load_json(EMOTIONS_FILE)
    
    new_emotion = {
        "email": data['email'],
        "emotion": data['emotion'],
        "note": data['note'],
        "date": datetime.now().isoformat()
    }
    emotions.append(new_emotion)
    save_json(EMOTIONS_FILE, emotions)
    return jsonify({"message": "Emoción guardada exitosamente"}), 201

@app.route('/emotions/<email>', methods=['GET'])
def get_emotions(email):
    emotions = load_json(EMOTIONS_FILE)
    user_emotions = [emotion for emotion in emotions if emotion['email'] == email]
    return jsonify(user_emotions), 200

@app.route('/exercise', methods=['POST'])
def save_exercise():
    data = request.json
    exercises = load_json(EXERCISES_FILE)
    
    new_exercise = {
        "email": data['email'],
        "nombre": data['nombre'],
        "descripcion": data['descripcion'],
        "duracion": data['duracion'],
        "fecha": datetime.now().isoformat()
    }
    exercises.append(new_exercise)
    save_json(EXERCISES_FILE, exercises)
    return jsonify({"message": "Ejercicio guardado exitosamente"}), 201

@app.route('/exercises/<email>', methods=['GET'])
def get_exercises(email):
    exercises = load_json(EXERCISES_FILE)
    user_exercises = [exercise for exercise in exercises if exercise['email'] == email]
    return jsonify(user_exercises), 200

@app.route('/exercise/<email>/<nombre>/<fecha>', methods=['DELETE'])
def delete_exercise(email, nombre, fecha):
    exercises = load_json(EXERCISES_FILE)
    exercises = [e for e in exercises if not (e['email'] == email and e['nombre'] == nombre and e['fecha'] == fecha)]
    save_json(EXERCISES_FILE, exercises)
    return jsonify({"message": "Ejercicio eliminado exitosamente"}), 200

if __name__ == '__main__':
    app.run(debug=True)