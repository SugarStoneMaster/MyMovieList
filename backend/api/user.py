import json
import os
from http.client import HTTPException, responses

from flask import Blueprint, request, jsonify
from backend.db import *
from flask_cors import CORS

user_api = Blueprint(
    'user_api', 'user_api', url_prefix='/api/user')

CORS(user_api)

@user_api.route('/add_movie_to_user_list', methods=['POST'])
def api_add_movie_to_user_list():
    data = request.get_json()
    user_id = data.get("user_id")
    movie_id = data.get("movie_id")
    title = data.get("title")
    poster = data.get("poster")
    watched = data.get("watched")
    watched = watched.lower() == 'true'

    if not all([user_id, movie_id, title, poster, watched is not None]):
        return jsonify({"error": "Missing required parameters"}), 400

    result = add_movie_to_user_list(user_id, movie_id, title, poster, watched)

    if result.modified_count > 0:
        return jsonify({"message": "Successfully added movie."}), 200
    else:
        return jsonify({"message": "No documents were added."}), 404


@user_api.route('/update_movie_in_user_list', methods=['POST'])
def api_update_movie_in_user_list():
    data = request.get_json()
    user_id = data.get('user_id')
    movie_id = data.get('movie_id')
    watched = data.get('watched')
    watched = watched.lower() == 'true'


    if not all([user_id, movie_id, watched is not None]):
        return jsonify({"error": "Missing required parameters"}), 400

    result = update_movie_in_user_list(user_id, movie_id, watched)

    if result.modified_count > 0:
        return jsonify({"message": "Successfully updated the movie's watched status."}), 200
    else:
        return jsonify({"message": "No documents were updated. Either the user or movie was not found."}), 404


@user_api.route('/delete_movie_from_user_list/<user_id>/<movie_id>', methods=['DELETE'])
def api_delete_movie_from_user_list(user_id: str, movie_id: str):
    try:
        result = delete_movie_from_user_list(user_id, movie_id)

        if result.modified_count > 0:
            return json.dumps({"message": "Movie removed successfully."}), 200
        else:
            return json.dumps({"Movie not found in user's list.": responses[404]}), 404  # 404 Not Found

    except (TypeError, ValueError):
        return json.dumps({"Invalid user ID or movie ID format.": responses[400]}), 400  # 400 Bad Request
    except Exception as e:
        return json.dumps({"Error deleting movie": responses[500]}), 500  # 500 Internal Server Error

@user_api.route('/get_movies_user_list/<user_id>/<watched>', methods=['GET'])
def api_get_movies_user_list(user_id, watched):
    # Convert the 'watched' parameter from string to boolean
    watched_bool = watched.lower() == 'true'
    # Retrieve the movies list based on the watched status
    movies_list = get_movies_user_list(user_id, watched_bool)
    return jsonify(movies_list)
