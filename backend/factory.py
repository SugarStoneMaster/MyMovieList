import os
import json 

from flask import Flask, render_template
from flask.json.provider import JSONProvider
from flask_cors import CORS

from bson import json_util, ObjectId
from datetime import datetime, timedelta

from api.movies import movies_api
from api.user import user_api


# https://stackoverflow.com/questions/44146087/pass-user-built-json-encoder-into-flasks-jsonify
class MongoJsonEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, datetime):
            return o.strftime("%Y-%m-%d %H:%M:%S")
        if isinstance(o, ObjectId):
            return str(o)
        return json_util.default(o, json_util.CANONICAL_JSON_OPTIONS)


class MongoJsonProvider(JSONProvider):
    def dumps(self, obj, **kwargs):
        return json.dumps(obj, **kwargs, cls=MongoJsonEncoder)
      
    def loads(self, s: str | bytes, **kwargs):
        return json.loads(s, **kwargs)


def create_app():
    APP_DIR = os.path.abspath(os.path.dirname(__file__))
    STATIC_FOLDER = os.path.join(APP_DIR, 'build/static')
    TEMPLATE_FOLDER = os.path.join(APP_DIR, 'build')

    app = Flask(__name__)
    CORS(app)
    app.register_blueprint(movies_api)
    app.register_blueprint(user_api)
    app.json = MongoJsonProvider(app)
    
    @app.route('/', defaults={'path': ''})
    @app.route('/<path:path>')
    def serve(path):
        return render_template('index.html')

    return app