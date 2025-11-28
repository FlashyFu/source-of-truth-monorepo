"""
============================================================================
006-flask-blueprint-app.py
Flask application with blueprint layout, config management, and migration hooks
============================================================================

HOW TO USE:
    1. Install dependencies: pip install flask flask-sqlalchemy python-dotenv
    2. Set environment variables: FLASK_SECRET_KEY, DATABASE_URL
    3. Run: flask run or python flask-blueprint-app.py
    4. Access: http://localhost:5000/api/health

STRUCTURE (recommended project layout):
    myapp/
    ├── app/
    │   ├── __init__.py         (create_app factory)
    │   ├── config.py           (configuration classes)
    │   ├── models/             (SQLAlchemy models)
    │   ├── blueprints/
    │   │   ├── auth/           (authentication routes)
    │   │   ├── api/            (API routes)
    │   │   └── main/           (main routes)
    │   └── utils/              (helpers)
    ├── migrations/             (Alembic migrations)
    ├── tests/
    └── run.py

============================================================================
"""

import os
from datetime import datetime
from functools import wraps

from flask import Flask, Blueprint, jsonify, request, g
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

# =============================================================================
# Configuration
# =============================================================================

class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('FLASK_SECRET_KEY', 'dev-secret-change-in-production')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL', 'sqlite:///app.db')
    
    # Security settings
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'


class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True
    SESSION_COOKIE_SECURE = False


class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False


class TestingConfig(Config):
    """Testing configuration."""
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'


config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
}

# =============================================================================
# Extensions
# =============================================================================

db = SQLAlchemy()

# =============================================================================
# Models
# =============================================================================

class User(db.Model):
    """User model."""
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(256), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'email': self.email,
            'name': self.name,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat(),
        }

# =============================================================================
# Blueprints
# =============================================================================

# --- Health/Main Blueprint ---
main_bp = Blueprint('main', __name__)

@main_bp.route('/health')
def health_check():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0',
    })


# --- API Blueprint ---
api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.before_request
def log_request():
    """Log incoming requests."""
    g.request_start = datetime.utcnow()


@api_bp.after_request
def log_response(response):
    """Log response details."""
    if hasattr(g, 'request_start'):
        duration = (datetime.utcnow() - g.request_start).total_seconds()
        # In production, use proper logging
        print(f"{request.method} {request.path} - {response.status_code} ({duration:.3f}s)")
    return response


@api_bp.route('/users', methods=['GET'])
def list_users():
    """List all users."""
    users = User.query.filter_by(is_active=True).all()
    return jsonify({
        'users': [user.to_dict() for user in users],
        'count': len(users),
    })


@api_bp.route('/users', methods=['POST'])
def create_user():
    """Create a new user."""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    required_fields = ['email', 'password', 'name']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'Email already registered'}), 409
    
    user = User(email=data['email'], name=data['name'])
    user.set_password(data['password'])
    
    db.session.add(user)
    db.session.commit()
    
    return jsonify({
        'message': 'User created successfully',
        'user': user.to_dict(),
    }), 201


@api_bp.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """Get a specific user."""
    user = User.query.get_or_404(user_id)
    return jsonify(user.to_dict())


# --- Auth Blueprint ---
auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

@auth_bp.route('/login', methods=['POST'])
def login():
    """Login endpoint (simplified - use JWT in production)."""
    data = request.get_json()
    
    if not data or 'email' not in data or 'password' not in data:
        return jsonify({'error': 'Email and password required'}), 400
    
    user = User.query.filter_by(email=data['email']).first()
    
    if not user or not user.check_password(data['password']):
        return jsonify({'error': 'Invalid credentials'}), 401
    
    if not user.is_active:
        return jsonify({'error': 'Account disabled'}), 403
    
    # In production, return JWT token here
    return jsonify({
        'message': 'Login successful',
        'user': user.to_dict(),
    })

# =============================================================================
# Error Handlers
# =============================================================================

def register_error_handlers(app):
    """Register error handlers."""
    
    @app.errorhandler(400)
    def bad_request(error):
        return jsonify({'error': 'Bad request'}), 400
    
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'error': 'Resource not found'}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return jsonify({'error': 'Internal server error'}), 500

# =============================================================================
# Application Factory
# =============================================================================

def create_app(config_name=None):
    """Application factory pattern."""
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')
    
    app = Flask(__name__)
    app.config.from_object(config_by_name[config_name])
    
    # Initialize extensions
    db.init_app(app)
    
    # Register blueprints
    app.register_blueprint(main_bp)
    app.register_blueprint(api_bp)
    app.register_blueprint(auth_bp)
    
    # Register error handlers
    register_error_handlers(app)
    
    # Create database tables
    with app.app_context():
        db.create_all()
    
    return app

# =============================================================================
# CLI Commands (for migrations)
# =============================================================================

def register_cli_commands(app):
    """Register CLI commands for database management."""
    
    @app.cli.command('init-db')
    def init_db():
        """Initialize the database."""
        db.create_all()
        print('Database initialized.')
    
    @app.cli.command('seed-db')
    def seed_db():
        """Seed the database with sample data."""
        user = User(email='admin@example.com', name='Admin User')
        user.set_password('admin123')
        db.session.add(user)
        db.session.commit()
        print('Database seeded.')

# =============================================================================
# Main Entry Point
# =============================================================================

if __name__ == '__main__':
    app = create_app()
    register_cli_commands(app)
    app.run(host='0.0.0.0', port=5000)

"""
============================================================================
PRODUCTION CHECKLIST:
- [ ] Use environment variables for all secrets
- [ ] Implement proper JWT authentication
- [ ] Set up Flask-Migrate for database migrations
- [ ] Add request validation (Flask-WTF, Marshmallow)
- [ ] Implement proper logging (structlog, python-json-logger)
- [ ] Add rate limiting (Flask-Limiter)
- [ ] Set up CORS properly (Flask-CORS)
- [ ] Use connection pooling for database
- [ ] Implement health checks for load balancers
- [ ] Add OpenTelemetry for observability

MIGRATION SETUP (Flask-Migrate):
    pip install flask-migrate
    
    # In app factory:
    from flask_migrate import Migrate
    migrate = Migrate()
    migrate.init_app(app, db)
    
    # Commands:
    flask db init
    flask db migrate -m "Initial migration"
    flask db upgrade
============================================================================
"""
