import json
from datetime import datetime
from http.client import responses

from db import get_troupe
from flask import Blueprint, request, jsonify
from flask_cors import CORS

troupe_api = Blueprint(
    'troupe_api', 'troupe_api', url_prefix='/api/troupe')

CORS(troupe_api)


@troupe_api.route('/get_troupe/<troupe_id>', methods=['GET'])
def api_get_troupe(troupe_id):
    return get_troupe(troupe_id)

