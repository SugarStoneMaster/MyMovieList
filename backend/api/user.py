import json
from datetime import datetime
from http.client import responses

from db import get_movie, add_movie_to_user_list, update_movie_in_user_list, delete_movie_from_user_list, \
    get_movies_user_list, add_review, update_review, apple_sign_in
from flask import Blueprint, request, jsonify
from flask_cors import CORS

user_api = Blueprint(
    'user_api', 'user_api', url_prefix='/api/user')

CORS(user_api)


@user_api.route("/apple_sign_in", methods=['POST'])
def api_apple_sign_in():
    data = request.get_json()
    email = data['email']
    username = data['username']
    return apple_sign_in(email, username)


@user_api.route('/add_movie_to_user_list', methods=['POST'])
def api_add_movie_to_user_list():
    data = request.get_json()
    user_id = data.get("user_id")
    movie_id = data.get("movie_id")
    title = data.get("title")
    poster = data.get("poster")
    watched = data.get("watched")
    watched = watched.lower() == 'true'
    favourite = data.get("favourite")
    favourite = favourite.lower() == 'true'

    print(data)
    #if not all([user_id, movie_id, title, poster, watched, favourite is not None]):
    #return jsonify({"error": "Missing required parameters"}), 400

    result = add_movie_to_user_list(user_id, movie_id, title, poster, watched, favourite)

    if result.modified_count > 0:
        return jsonify({"message": "Successfully added movie."}), 200
    else:
        return jsonify({"message": "No documents were added."}), 200


@user_api.route('/update_movie_in_user_list', methods=['POST'])
def api_update_movie_in_user_list():
    data = request.get_json()
    user_id = data.get('user_id')
    movie_id = data.get('movie_id')
    watched = data.get('watched')
    watched = watched.lower() == 'true'
    favourite = data.get('favourite')
    favourite = favourite.lower() == 'true'

    #if not all([user_id, movie_id, watched, favourite is not None]):
    #return jsonify({"error": "Missing required parameters"}), 400

    result = update_movie_in_user_list(user_id, movie_id, watched, favourite)

    if result.modified_count > 0:
        return jsonify({"message": "Successfully updated the movie's watched status."}), 200
    else:
        return jsonify({"message": "No documents were updated. Either the user or movie was not found."}), 200


@user_api.route('/delete_movie_from_user_list/<user_id>/<movie_id>', methods=['DELETE'])
def api_delete_movie_from_user_list(user_id: str, movie_id: str):
    try:
        result = delete_movie_from_user_list(user_id, movie_id)

        if result.modified_count > 0:
            return json.dumps({"message": "Movie removed successfully."}), 200
        else:
            return json.dumps({"Movie not found in user's list.": responses[404]}), 200  # 404 Not Found

    except (TypeError, ValueError):
        return json.dumps({"Invalid user ID or movie ID format.": responses[400]}), 400  # 400 Bad Request
    except Exception as e:
        return json.dumps({"Error deleting movie": responses[500]}), 500  # 500 Internal Server Error


@user_api.route('/get_movies_user_list/<user_id>/<watched>/<favourite>', methods=['GET'])
def api_get_movies_user_list(user_id, watched, favourite):
    watched = watched.lower() == 'true'
    favourite = favourite.lower() == 'true'
    movies_list = get_movies_user_list(user_id, watched, favourite)
    return jsonify(movies_list)


@user_api.route('/add_review/<movie_id>', methods=['POST'])
def api_add_review(movie_id):
    data = request.get_json()
    username = data.get('username')
    user_id = data.get('user_id')
    title = data.get('title')
    content = data.get('content')
    vote = data.get('vote')
    date = datetime.now()

    if not all([user_id, title, content, vote, date, movie_id]):
        return jsonify({"error": "Missing required parameters"}), 400

    if not get_movie(movie_id=movie_id):
        return jsonify({"error": "The movie you are trying to review does not exist."}), 200

    # Add the review to the movie document
    result = add_review(user_id=user_id, username=username, title=title, content=content,
                        movie_id=movie_id, vote=vote, date=date)

    if result:
        return jsonify({"message": "Successfully added review."}), 200
    else:
        return jsonify({"message": "No review were added."}), 200


@user_api.route('/update_review/<review_id>', methods=['POST'])
def api_update_review(review_id):
    data = request.get_json()
    title = data.get('title')
    content = data.get('content')
    vote = data.get('vote')
    date = datetime.now()

    if not all([title, content, vote, date, review_id]):
        return jsonify({"error": "Missing required parameters"}), 400

    # Add the review to the movie document
    result = update_review(review_id=review_id, title=title, content=content,
                           vote=vote, date=date)

    if result:
        return jsonify({"message": "Successfully updated review."}), 200
    else:
        return jsonify({"message": "No review was updated."}), 200
