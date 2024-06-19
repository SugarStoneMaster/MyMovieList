import os
from flask import Blueprint, request, jsonify
from db import get_movies, get_movies_by_release_year, sort_movies
from flask_cors import CORS

movies_api = Blueprint(
    'movies_api', 'movies_api', url_prefix='/api/movies')

CORS(movies_api)
DEFAULT_ITEMS_PER_PAGE = os.getenv('DEFAULT_ITEMS_PER_PAGE')
DEFAULT_ITEMS_PER_PAGE = int(DEFAULT_ITEMS_PER_PAGE) if DEFAULT_ITEMS_PER_PAGE else 20


def paginate_movies(get_movies_func, **kwargs):
    try:
        page = int(request.args.get('page', 0))
    except (TypeError, ValueError) as e:
        print('Got bad value:', e)
        page = 0

    offset = page * DEFAULT_ITEMS_PER_PAGE
    try:
        movies, total_results = get_movies_func(offset=offset, movies_per_page=DEFAULT_ITEMS_PER_PAGE, **kwargs)
    except TypeError as e:
        print('Got bad value:', e)
        return {}

    response = {
        "movies": movies,
        "page": page,
        "entries_per_page": DEFAULT_ITEMS_PER_PAGE,
        "total_results": total_results
    }

    return jsonify(response)


@movies_api.route('/', methods=['GET'])
def api_get_movies():
    return paginate_movies(get_movies)


@movies_api.route('/release_year/<int:year>', methods=['GET'])
def api_get_movies_by_release_year(year):
    return paginate_movies(get_movies_by_release_year, release_year=year)


@movies_api.route('/sort/<field>/<int:order>', methods=['GET'])
def api_sort_movies(field, order):
    return paginate_movies(sort_movies, field=field, order=order)
