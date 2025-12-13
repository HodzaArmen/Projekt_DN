from flask import Flask, render_template, request, redirect
import sqlite3
import redis
import json
import os

DB_PATH = "/app/data/tasks.db"


# Ustvarimo Flask aplikacijo
app = Flask(__name__)

# Povezava z Redis cache-om (za hitrejši dostop do seznama nalog)
r = redis.Redis(
    host=os.getenv("REDIS_HOST", "redis"),
    port=int(os.getenv("REDIS_PORT", "6379")),
    decode_responses=True
)
# Funkcija za inicializacijo baze (ustvari tabelo, če ne obstaja)
def init_db():
    conn = sqlite3.connect(DB_PATH)  # odpri SQLite bazo
    c = conn.cursor()
    # ustvari tabelo "tasks" s stolpci id in task, če ne obstaja
    c.execute('''CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, task TEXT)''')
    conn.commit()  # shrani spremembe
    conn.close()   # zapri povezavo

# Glavna stran aplikacije
@app.route('/')
def index():
    # Poskusimo pridobiti naloge iz Redis cache-a
    cached = r.get('tasks')
    if cached:
        # Če so v cache-u, jih deserializiramo iz JSON-a
        tasks = json.loads(cached)
    else:
        # Če ni cache-a, jih vzamemo iz SQLite baze
        conn = sqlite3.connect(DB_PATH)
        c = conn.cursor()
        c.execute('SELECT * FROM tasks')
        tasks = [{"id": row[0], "task": row[1]} for row in c.fetchall()]
        conn.close()
        # shranimo rezultat v Redis cache za 15 sekund
        r.set('tasks', json.dumps(tasks), ex=15)
    # Render HTML strani s seznamom nalog
    return render_template('index.html', tasks=tasks)

# Dodajanje nove naloge
@app.route('/add', methods=['POST'])
def add():
    task = request.form['task']  # preberi nalogo iz forme
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    # vstavi novo nalogo v bazo
    c.execute('INSERT INTO tasks (task) VALUES (?)', (task,))
    conn.commit()
    conn.close()
    # izbriši cache, da bo naslednji GET posodobil podatke
    r.delete('tasks')
    return redirect('/')  # preusmeri nazaj na glavno stran

# Brisanje naloge po id
@app.route('/delete/<int:id>')
def delete(id):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    # izbriši nalogo iz baze
    c.execute('DELETE FROM tasks WHERE id=?', (id,))
    conn.commit()
    conn.close()
    # izbriši cache, da se osveži seznam
    r.delete('tasks')
    return redirect('/')  # preusmeri nazaj na glavno stran

# Zaženi aplikacijo, če se datoteka zažene neposredno
if __name__ == '__main__':
    init_db()  # inicializacija baze
    app.run(host='0.0.0.0', port=5000)  # zaženi na vseh IP-jevih, port 5000
