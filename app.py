from flask import Flask, render_template, request, redirect, url_for, flash
from werkzeug.utils import secure_filename
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os

app = Flask(__name__)

# Configure Flask and SQLAlchemy
app.config['SECRET_KEY'] = 'your-secret-key-here'  # Required for flash messages
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///inspections.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = 'static/uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

db = SQLAlchemy(app)

# Models
class Inspection(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    client_name = db.Column(db.String(100), nullable=False)
    address = db.Column(db.String(200), nullable=False)
    inspection_date = db.Column(db.DateTime, default=datetime.utcnow)
    notes = db.Column(db.Text)
    findings = db.relationship('Finding', backref='inspection', lazy=True)

class Finding(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    category = db.Column(db.String(50), nullable=False)
    description = db.Column(db.Text, nullable=False)
    image_path = db.Column(db.String(200))
    inspection_id = db.Column(db.Integer, db.ForeignKey('inspection.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# Routes
@app.route('/')
def home():
    inspections = Inspection.query.order_by(Inspection.inspection_date.desc()).all()
    return render_template('home.html', inspections=inspections)

@app.route('/inspection/new', methods=['GET', 'POST'])
def new_inspection():
    if request.method == 'POST':
        inspection = Inspection(
            client_name=request.form['client_name'],
            address=request.form['address'],
            notes=request.form.get('notes', '')
        )
        db.session.add(inspection)
        db.session.commit()
        return redirect(url_for('home'))
    return render_template('new_inspection.html')

@app.route('/inspection/<int:id>')
def view_inspection(id):
    inspection = Inspection.query.get_or_404(id)
    return render_template('view_inspection.html', inspection=inspection)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/inspection/<int:inspection_id>/finding', methods=['POST'])
def add_finding(inspection_id):
    inspection = Inspection.query.get_or_404(inspection_id)
    
    category = request.form['category']
    description = request.form['description']
    image = request.files.get('image')
    
    image_path = None
    if image and allowed_file(image.filename):
        filename = secure_filename(image.filename)
        # Create unique filename using timestamp
        unique_filename = f"{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}_{filename}"
        image_path = os.path.join('uploads', unique_filename)
        image.save(os.path.join(app.static_folder, image_path))
    
    finding = Finding(
        category=category,
        description=description,
        image_path=image_path,
        inspection_id=inspection_id
    )
    
    db.session.add(finding)
    db.session.commit()
    flash('Finding added successfully!', 'success')
    
    return redirect(url_for('view_inspection', id=inspection_id))

if __name__ == '__main__':
    # Create upload directory if it doesn't exist
    os.makedirs(os.path.join(app.static_folder, 'uploads'), exist_ok=True)
    
    # Create database tables
    with app.app_context():
        db.create_all()
    
    app.run(debug=True)
