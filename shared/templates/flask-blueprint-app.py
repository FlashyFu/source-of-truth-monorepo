# Minimal Flask application with blueprint pattern, config handling, and a migration hook.
#
# Usage:
#   FLASK_APP=flask-blueprint-app.py FLASK_ENV=development flask run

from flask import Flask, Blueprint, jsonify, request, current_app
from werkzeug.exceptions import HTTPException
import os

def create_app(config=None):
    app = Flask(__name__)
    # Load default config
    app.config.from_mapping(
        SECRET_KEY=os.environ.get('SECRET_KEY', 'dev-secret'),
        DATABASE_URL=os.environ.get('DATABASE_URL', 'sqlite:///:memory:'),
    )
    if config:
        app.config.update(config)

    # Register blueprints
    from auth import auth_bp
    app.register_blueprint(auth_bp, url_prefix='/auth')

    from api import api_bp
    app.register_blueprint(api_bp, url_prefix='/api')

    # Error handling
    @app.errorhandler(Exception)
    def handle_error(e):
        code = 500
        if isinstance(e, HTTPException):
            code = e.code
        current_app.logger.exception(e)
        return jsonify({'error': str(e)}), code

    return app

# auth blueprint
auth_bp = Blueprint('auth', __name__)
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    if data.get('username') == 'admin' and data.get('password') == 'secret':
        return jsonify({'token': 'fake-token-for-demo'})
    return jsonify({'error': 'invalid credentials'}), 401

# api blueprint
api_bp = Blueprint('api', __name__)
@api_bp.route('/profile')
def profile():
    # For demo: return a static profile
    return jsonify({'id': 1, 'name': 'Demo User'})

# Migration hook: simple function to be invoked by CI or deploy scripts
def run_migrations():
    # Example: run Alembic or custom SQL migrations
    print("Running migrations against", os.environ.get('DATABASE_URL'))

if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)), debug=True)
