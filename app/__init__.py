from flask import Flask, jsonify, render_template
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os

db = SQLAlchemy()

def create_app():
    app = Flask(__name__, template_folder='templates')
    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///vitalaxis.db')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db.init_app(app)
    
    class User(db.Model):
        id = db.Column(db.Integer, primary_key=True)
        username = db.Column(db.String(80), unique=True)
        email = db.Column(db.String(120))
        created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    class TimeEntry(db.Model):
        id = db.Column(db.Integer, primary_key=True)
        user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
        duration = db.Column(db.Integer)
        category = db.Column(db.String(50))
        date = db.Column(db.Date, default=datetime.utcnow)
    
    class Transaction(db.Model):
        id = db.Column(db.Integer, primary_key=True)
        user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
        amount = db.Column(db.Float)
        category = db.Column(db.String(50))
        date = db.Column(db.Date, default=datetime.utcnow)
    
    @app.route('/')
    def index():
        return render_template('index.html')
    
    @app.route('/dashboard')
    def dashboard():
        return render_template('dashboard.html')
    
    @app.route('/health')
    def health():
        with app.app_context():
            db.create_all()
        return jsonify({"status": "healthy", "database": "connected"})
    
    return app

app = create_app()
