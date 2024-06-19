import os
from flask import Blueprint, request, jsonify
from db import get_movies, get_movies_by_release_year, sort_movies, get_movies_by_genres, get_movie_reviews, get_movie
from flask_cors import CORS

movies_api = Blueprint(
    'movies_api', 'movies_api', url_prefix='/api/movies')

CORS(movies_api)
DEFAULT_ITEMS_PER_PAGE = os.getenv('DEFAULT_ITEMS_PER_PAGE')
DEFAULT_ITEMS_PER_PAGE = int(DEFAULT_ITEMS_PER_PAGE) if DEFAULT_ITEMS_PER_PAGE else 20


def paginate_items(get_movies_func, **kwargs):
    try:
        page = int(request.args.get('page', 0))
    except (TypeError, ValueError) as e:
        print('Got bad value:', e)
        page = 0

    offset = page * DEFAULT_ITEMS_PER_PAGE
    try:
        movies, total_results = get_movies_func(offset=offset, items_per_page=DEFAULT_ITEMS_PER_PAGE, **kwargs)
    except TypeError as e:
        print('Got bad value:', e)
        return {}

    response = {
        "items": movies,
        "page": page,
        "entries_per_page": DEFAULT_ITEMS_PER_PAGE,
        "total_results": total_results
    }

    return jsonify(response)


@movies_api.route('/get_movies/<text>', methods=['GET'])
def api_get_movies(text):
    return paginate_items(get_movies, text=text)

@movies_api.route('/get_movies_by_genres', methods=['GET'])
def api_get_movies_by_genres():
    genres = request.args.getlist('genres')
    return paginate_items(get_movies_by_genres, genres=genres)

@movies_api.route('/release_year/<int:year>', methods=['GET'])
def api_get_movies_by_release_year(year):
    return paginate_items(get_movies_by_release_year, release_year=year)


@movies_api.route('/sort/<field>/<order>', methods=['GET'])
def api_sort_movies(field, order):
    return paginate_items(sort_movies, field=field, order=order)

@movies_api.route('/reviews/<movie_id>', methods=['GET'])
def api_get_movies_reviews(movie_id):
    return paginate_items(get_movie_reviews, movie_id=movie_id)

@movies_api.route('/get_movie/<movie_id>', methods=['GET'])
def api_get_movie(movie_id):
    return get_movie(movie_id)

