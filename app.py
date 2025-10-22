from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_mail import Mail, Message
from datetime import datetime
import os
import json
from werkzeug.utils import secure_filename

app = Flask(__name__)

# Konfiguráció
app.config['SECRET_KEY'] = 'bori-birthday-2026-secret-key'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///rsvp.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Email konfiguráció (Gmail SMTP)
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.environ.get('MAIL_USERNAME', 'your-email@gmail.com')
app.config['MAIL_PASSWORD'] = os.environ.get('MAIL_PASSWORD', 'your-app-password')

# Inicializálás
db = SQLAlchemy(app)
mail = Mail(app)

# Adatbázis modell
class RSVP(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    phone = db.Column(db.String(20))
    attendance = db.Column(db.String(20), nullable=False)
    guests = db.Column(db.String(10))
    dietary = db.Column(db.Text)
    message = db.Column(db.Text)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'phone': self.phone,
            'attendance': self.attendance,
            'guests': self.guests,
            'dietary': self.dietary,
            'message': self.message,
            'timestamp': self.timestamp.isoformat()
        }

# Főoldal
@app.route('/')
def index():
    return send_from_directory('.', 'Bori_szuletesnap.html')

# Statikus fájlok
@app.route('/<path:filename>')
def static_files(filename):
    return send_from_directory('.', filename)

# RSVP API végpontok
@app.route('/api/rsvp', methods=['POST'])
def create_rsvp():
    try:
        data = request.get_json()
        
        # Validáció
        required_fields = ['name', 'email', 'attendance']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} mező kötelező'}), 400
        
        # Új RSVP létrehozása
        rsvp = RSVP(
            name=data['name'],
            email=data['email'],
            phone=data.get('phone', ''),
            attendance=data['attendance'],
            guests=data.get('guests', '1'),
            dietary=data.get('dietary', ''),
            message=data.get('message', '')
        )
        
        db.session.add(rsvp)
        db.session.commit()
        
        # Email küldése (opcionális)
        try:
            send_confirmation_email(rsvp)
        except Exception as e:
            print(f"Email küldési hiba: {e}")
        
        return jsonify({
            'message': 'RSVP sikeresen mentve!',
            'rsvp': rsvp.to_dict()
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/rsvp', methods=['GET'])
def get_rsvps():
    try:
        rsvps = RSVP.query.order_by(RSVP.timestamp.desc()).all()
        return jsonify([rsvp.to_dict() for rsvp in rsvps])
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/rsvp/<int:rsvp_id>', methods=['GET'])
def get_rsvp(rsvp_id):
    try:
        rsvp = RSVP.query.get_or_404(rsvp_id)
        return jsonify(rsvp.to_dict())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/rsvp/<int:rsvp_id>', methods=['DELETE'])
def delete_rsvp(rsvp_id):
    try:
        rsvp = RSVP.query.get_or_404(rsvp_id)
        db.session.delete(rsvp)
        db.session.commit()
        return jsonify({'message': 'RSVP törölve'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Admin felület
@app.route('/admin')
def admin():
    rsvps = RSVP.query.order_by(RSVP.timestamp.desc()).all()
    stats = {
        'total': len(rsvps),
        'yes': len([r for r in rsvps if r.attendance == 'yes']),
        'maybe': len([r for r in rsvps if r.attendance == 'maybe']),
        'no': len([r for r in rsvps if r.attendance == 'no'])
    }
    return render_template('admin.html', rsvps=rsvps, stats=stats)

# Email küldés funkció
def send_confirmation_email(rsvp):
    msg = Message(
        subject='RSVP megerősítés - Bori születésnapja',
        sender=app.config['MAIL_USERNAME'],
        recipients=[rsvp.email]
    )
    
    attendance_text = {
        'yes': 'Igen, megyek! 🎉',
        'maybe': 'Talán 🤔',
        'no': 'Sajnos nem tudok menni 😢'
    }
    
    msg.body = f"""
Kedves {rsvp.name}!

Köszönjük, hogy RSVP-t küldtél Borinak a 16. születésnapjára!

Részletek:
- Név: {rsvp.name}
- Email: {rsvp.email}
- Telefon: {rsvp.phone or 'Nem megadva'}
- Részt veszel: {attendance_text.get(rsvp.attendance, rsvp.attendance)}
- Vendégek száma: {rsvp.guests}
- Étkezési preferenciák: {rsvp.dietary or 'Nincs megadva'}
- Üzenet: {rsvp.message or 'Nincs üzenet'}

Az esemény részletei:
📅 Dátum: 2026. március 14-15.
📍 Helyszín: Papp László Aréna
🎉 Meglepetéskoncert Borinak!

Ha bármilyen kérdésed van, ne habozz felvenni velünk a kapcsolatot!

Sok szeretettel,
A szervezők 💖
    """
    
    mail.send(msg)

# Statisztikák API
@app.route('/api/stats')
def get_stats():
    try:
        rsvps = RSVP.query.all()
        stats = {
            'total': len(rsvp),
            'yes': len([r for r in rsvps if r.attendance == 'yes']),
            'maybe': len([r for r in rsvps if r.attendance == 'maybe']),
            'no': len([r for r in rsvps if r.attendance == 'no']),
            'total_guests': sum([int(r.guests) if r.guests.isdigit() else 1 for r in rsvps if r.attendance == 'yes'])
        }
        return jsonify(stats)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Health check
@app.route('/health')
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})

# Adatbázis inicializálás
@app.before_first_request
def create_tables():
    db.create_all()

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, host='0.0.0.0', port=5000)
