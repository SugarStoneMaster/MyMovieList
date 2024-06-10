"""
This module contains all database interfacing methods for the MFlix
application. You will be working on this file for the majority of M220P.

Each method has a short description, and the methods you must implement have
docstrings with a short explanation of the task.

Look out for TODO markers for additional help. Good luck!
"""
import bson

from flask import current_app, g
from werkzeug.local import LocalProxy
from flask_pymongo import PyMongo
from pymongo.errors import DuplicateKeyError, OperationFailure
from bson.objectid import ObjectId
from bson.errors import InvalidId
from typing import Union, Optional

import os

from pymongo import MongoClient
from dotenv import load_dotenv, dotenv_values

from typing import Optional, Union, List, Tuple
from pymongo.collection import Collection

# loading variables from .env file
load_dotenv()


def get_db_name():
    return os.getenv("DB_NAME")


def get_db_user():
    return os.getenv("DB_USER")


def get_db_password():
    return os.getenv("DB_PASSWORD")


def get_db_host():
    return os.getenv("DB_HOST")


def get_db_port():
    return os.getenv("DB_PORT")


def get_connection_string():
    db_user = get_db_user()
    db_password = get_db_password()
    db_host = get_db_host()
    db_port = get_db_port()
    db_name = get_db_name()

    return f"mongodb://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}?retryWrites=true&w=majority"


def open_connection():
    return MongoClient(get_connection_string())


def close_connection(client):
    client.close()


def get_db():
    """
    Configuration method to return db instance
    """
    db = getattr(g, "_database", None)

    if db is None:
        client = open_connection()
        db_name = get_db_name()

        if db_name is None:
            raise ValueError("DB_NAME is not set in .env file")

        db = g._database = getattr(client, db_name)

    return db


# Use LocalProxy to read the global db instance with just `db`
db = LocalProxy(get_db)


def paginate_query(collection, query, offset: int, limit: int):
    """
    Paginate a MongoDB query.

    :param collection: The collection from which you want to paginate.
    :param query: The MongoDB query to paginate.
    :param offset: The number of documents to skip.
    :param limit: The maximum number of documents to return.
    :return: A tuple containing the paginated results and the total count of documents.
    """
    results = query.skip(offset).limit(limit)
    total_count = collection.count_documents({})
    return list(results), total_count


def project_movies(query, projection):
    """
    Project fields for a MongoDB query.

    :param query: The MongoDB query to project fields from.
    :param projection: The fields to include or exclude.
    :return: A MongoDB query with projection applied.
    """
    return query.project(projection)


def get_movies(offset: int, movies_per_page: int, title: Optional[str] = None,
               directors: Optional[Union[str, List[str]]] = None,
               actors: Optional[Union[str, List[str]]] = None, projection: Optional[dict] = None) \
        -> Union[Tuple[List[dict], int], Exception]:
    """
    Get movies based on title, directors, and actors.

    :param offset: The number of documents to skip.
    :param movies_per_page: The maximum number of movies to return per page.
    :param title: The title of the movie.
    :param directors: Directors of the movie.
    :param actors: Actors starring in the movie.
    :param projection: The fields to include or exclude in the result.
    :return: A tuple containing the list of movies for the given page and the total count of movies that match
        the query criteria or an Exception if an error occurs.
    """

    try:
        query = {}

        if title:
            query["title"] = title

        if directors:
            if isinstance(directors, str):
                directors = [directors]
            query["directors"] = {"$in": directors}

        if actors:
            if isinstance(actors, str):
                actors = [actors]
            query["cast"] = {"$in": actors}

        # Default projection if not provided
        default_projection = {"_id": 1, "title": 1, "poster": 1, "release_year": 1, "popularity": 1, "vote_average": 1}
        projection = projection or default_projection

        # Construct the MongoDB query with projection
        movie_query = db.movie.find(query, projection)

        # Paginate the query
        movies, total_movies = paginate_query(db.movie, movie_query, offset, movies_per_page)

        return movies, total_movies
    except Exception as e:
        return e


def get_movies_by_genres(offset: int, movies_per_page: int, genres: Union[List[str], str],
                         projection: Optional[dict] = None) -> Union[Tuple[List[dict], int], Exception]:
    """
    Get movies based on genres with pagination and projection.

    :param projection: The fields to include or exclude in the result.
    :param offset: The number of documents to skip.
    :param movies_per_page: The maximum number of movies to return per page.
    :param genres: List of genres or a single genre.
    :return: A tuple containing the list of movies for the given page and the total count of movies that match the criteria,
             or an Exception if an error occurs.
    """
    try:
        query = {"genres": {"$all": genres} if isinstance(genres, list) else genres}

        # Default projection if not provided
        default_projection = {"_id": 1, "title": 1, "poster": 1, "release_year": 1, "popularity": 1, "vote_average": 1}
        projection = projection or default_projection

        # Construct the MongoDB query with projection
        movie_query = db.movie.find(query, projection)

        # Paginate the query
        return paginate_query(db.movie, movie_query, offset, movies_per_page)
    except Exception as e:
        return e


def get_movies_by_release_year(offset: int, movies_per_page: int, release_year: int,
                               projection: Optional[dict] = None) -> Union[Tuple[List[dict], int], Exception]:
    """
    Get movies released in a specific year with pagination and projection.

    :param projection: The fields to include or exclude in the result.
    :param offset: The number of documents to skip.
    :param movies_per_page: The maximum number of movies to return per page.
    :param release_year: The release year.
    :return: A tuple containing the list of movies for the given page and the total count of movies that match
        the criteria or an Exception if an error occurs.
    """
    try:
        query = {"release_year": release_year}

        # Default projection if not provided
        default_projection = {"_id": 1, "title": 1, "poster": 1, "release_year": 1, "popularity": 1, "vote_average": 1}
        projection = projection or default_projection

        # Construct the MongoDB query with projection
        movie_query = db.movie.find(query, projection)

        # Paginate the query
        return paginate_query(db.movie, movie_query, offset, movies_per_page)
    except Exception as e:
        return e


def sort_movies(offset: int, movies_per_page: int, field: str, order: int = -1,
                projection: Optional[dict] = None) -> Union[Tuple[List[dict], int], Exception]:
    """
    Get movies sorted in descending order by rating.

    :param order: The order to sort by.
    :param field: The field to sort by.
    :param projection: The fields to include or exclude in the result.
    :param offset: The number of documents to skip.
    :param movies_per_page: The maximum number of movies to return per page.
    :return: A tuple containing the list of movies for the given page and the total count of movies that match
        the criteria or an Exception if an error occurs.
    """
    try:
        # Default projection if not provided
        default_projection = {"_id": 1, "title": 1, "poster": 1, "release_year": 1, "popularity": 1, "vote_average": 1}
        projection = projection or default_projection

        # Construct the MongoDB query with projection
        movie_query = db.movie.find({}, projection).sort({field: order})

        # Paginate the query
        return paginate_query(db.movie, movie_query, offset, movies_per_page)
    except Exception as e:
        return e