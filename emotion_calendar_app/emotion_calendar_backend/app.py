from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

# Conexión y creación de la tabla
def connect_db():
    conn = sqlite3.connect('user_notes.db')
    return conn

def create_table(conn):
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_email TEXT NOT NULL,
            note TEXT NOT NULL
        )
    ''')
    conn.commit()

@app.route('/save_note', methods=['POST'])
def save_note():
    data = request.json
    user_email = data['user_email']
    note = data['note']
    conn = connect_db()
    create_table(conn)
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO notes (user_email, note) VALUES (?, ?)
    ''', (user_email, note))
    conn.commit()
    conn.close()
    return jsonify({'message': 'Nota guardada'}), 201

@app.route('/get_notes/<user_email>', methods=['GET'])
def get_notes(user_email):
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute('''
        SELECT note FROM notes WHERE user_email = ?
    ''', (user_email,))
    notes = cursor.fetchall()
    conn.close()
    return jsonify({'notes': [note[0] for note in notes]})

if __name__ == "__main__":
    app.run(debug=True)
