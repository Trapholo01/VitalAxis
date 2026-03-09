from flask import Flask, render_template, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os

# Create the Flask app with explicit template folder
app = Flask(__name__, 
            template_folder='templates',
            static_folder='static')

# Database configuration
database_url = os.environ.get('DATABASE_URL', 'sqlite:///vitalaxis.db')
if database_url.startswith('postgres://'):
    database_url = database_url.replace('postgres://', 'postgresql://', 1)

app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Import and initialize db
from app.models import db, User, TimeEntry, Transaction, Goal
db.init_app(app)

# Create tables safely
with app.app_context():
    try:
        db.create_all()
        print("✅ Database tables created successfully")
    except Exception as e:
        print(f"⚠️ Database tables may already exist: {e}")

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

@app.route('/time')
def time_tracker():
    return render_template('time.html')

@app.route('/budget')
def budget():
    return render_template('budget.html')

@app.route('/health')
def health():
    return {'status': 'healthy', 'database': 'connected'}, 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
