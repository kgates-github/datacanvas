import sqlite3
from flask import Flask


db = sqlite3.connect('db/datacanvas.db')


def create_app(config_name):
    '''Retuns flask app object based on config settings.
        Initializes DB and registers endpoints
    '''
    app = Flask(__name__)
    app.config.from_object(config_name)

    # register API endpoints as blueprints
    from app.blueprints import main
    app.register_blueprint(main)

    return app
