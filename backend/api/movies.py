from flask import Blueprint, request, jsonify
from db import get_movies, get_movies_by_genres, get_movies_by_release_year

from flask_cors import CORS
from datetime import datetime


movies_api = Blueprint(
    'movies_api', 'movies_api', url_prefix='/api/movies')

CORS(movies_api)

@movies_api.route('/', methods=['GET'])
def api_get_movies():
    MOVIES_PER_PAGE = 20
    
    movies = get_movies()

    response = {
        "movies": movies,
    }

    return jsonify(response)