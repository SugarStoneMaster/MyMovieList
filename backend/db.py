"""
This module contains all database interfacing methods for the MFlix
application. You will be working on this file for the majority of M220P.

Each method has a short description, and the methods you must implement have
docstrings with a short explanation of the task.

Look out for TODO markers for additional help. Good luck!
"""
import datetime
import os
from typing import Optional, Union, List, Tuple

from bson.objectid import ObjectId
from dotenv import load_dotenv
from flask import g
from pymongo import MongoClient
from werkzeug.local import LocalProxy

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
    app_db = getattr(g, "_database", None)

    if app_db is None:
        client = open_connection()
        db_name = get_db_name()

        if db_name is None:
            raise ValueError("DB_NAME is not set in .env file")

        app_db = g._database = getattr(client, db_name)

    return app_db


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


# MOVIES QUERIES -- START

def get_movies(offset: int, items_per_page: int, text: Optional[str] = None, projection: Optional[dict] = None) \
        -> Union[Tuple[List[dict], int], Exception]:
    """
        Get movies based on title, directors, and actors.
    
        :param offset: The number of documents to skip.
        :param items_per_page: The maximum number of movies to return per page.
        :param text: The field of the movie (title, actors, directors).
        :param projection: The fields to include or exclude in the result.
        :return: A tuple containing the list of movies for the given page and the total count of movies that match
            the query criteria or an Exception if an error occurs.
    """

    try:
        query = {}

        if text:
            text_list = text.split(",")
            query["title"] = text
            query["directors"] = {"$in": text_list}
            query["cast"] = {"$in": text_list}

        # Default projection if not provided
        default_projection = {"_id": 1, "title": 1, "poster": 1, "release_year": 1, "popularity": 1, "vote_average": 1}
        projection = projection or default_projection

        # Construct the MongoDB query with projection
        movie_query = db.movie.find(query, projection)

        # Paginate the query
        movies, total_movies = paginate_query(db.movie, movie_query, offset, items_per_page)

        return movies, total_movies
    except Exception as e:
        return e


def get_movies_by_genres(offset: int, items_per_page: int, genres: Union[List[str], str] = None,
                         projection: Optional[dict] = None) -> Union[Tuple[List[dict], int], Exception]:
    """
        Get movies based on genres with pagination and projection.
    
        :param projection: The fields to include or exclude in the result.
        :param offset: The number of documents to skip.
        :param items_per_page: The maximum number of movies to return per page.
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
        return paginate_query(db.movie, movie_query, offset, items_per_page)
    except Exception as e:
        return e


def get_movies_by_release_year(offset: int, items_per_page: int, release_year: int,
                               projection: Optional[dict] = None) -> Union[Tuple[List[dict], int], Exception]:
    """
        Get movies released in a specific year with pagination and projection.
    
        :param projection: The fields to include or exclude in the result.
        :param offset: The number of documents to skip.
        :param items_per_page: The maximum number of movies to return per page.
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
        return paginate_query(db.movie, movie_query, offset, items_per_page)
    except Exception as e:
        return e


def sort_movies(offset: int, items_per_page: int, field: str, order: str = "-1",
                projection: Optional[dict] = None) -> Union[Tuple[List[dict], int], Exception]:
    """
        Get movies sorted in descending order by rating.
    
        :param order: The order to sort by.
        :param field: The field to sort by.
        :param projection: The fields to include or exclude in the result.
        :param offset: The number of documents to skip.
        :param items_per_page: The maximum number of movies to return per page.
        :return: A tuple containing the list of movies for the given page and the total count of movies that match
            the criteria or an Exception if an error occurs.
    """
    try:
        # Default projection if not provided
        default_projection = {"_id": 1, "title": 1, "poster": 1, "release_year": 1, "popularity": 1, "vote_average": 1}
        projection = projection or default_projection

        # Construct the MongoDB query with projection
        movie_query = db.movie.find({}, projection).sort({field: int(order)})

        # Paginate the query
        return paginate_query(db.movie, movie_query, offset, items_per_page)
    except Exception as e:
        return e


def get_movie_reviews(offset: int, items_per_page: int = None, movie_id: str = None) -> Union[Tuple[List[dict], int], Exception]:
    """
        Get a movie's reviews.
    
        :param offset: The number of documents to skip.
        :param items_per_page: The maximum number of movies to return per page.
        :param movie_id: The movie id.
        :return: A tuple containing the list of reviews for a given movie and the total count of reviews 
            or an Exception if an error occurs.
    """
    try:
        # Construct the MongoDB query with projection
        reviews_query = db.review.find({"movie_id": ObjectId(movie_id)})

        # Paginate the query
        return paginate_query(db.review, reviews_query, offset, items_per_page)
    except Exception as e:
        return e


def get_movie(movie_id: str):
    return db.movie.find_one({"_id": ObjectId(movie_id)})


# MOVIES QUERIES -- END


# USER QUERIES -- START

def add_movie_to_user_list(user_id: str, movie_id: str, title: str, poster: str, watched: bool, favourite: bool):
    """
       Add a movie to the user list.

       :param user_id: user id.
       :param movie_id: movie id.
       :param title: movie title.
       :param poster: movie poster.
       :param watched: if the movie is already watched or to watch.
       :param favourite: if the movie is favourite or not.
       :return: result of the query
    """
    if favourite:
        watched = True

    new_movie = {"_id": ObjectId(movie_id), "title": title, "poster": poster, "watched": watched,
                 "favourite": favourite}

    db.user.update_one({"_id": ObjectId(user_id)}, {"$push": {"movies_list": new_movie}})

    # use approximation pattern?
    result = db.movie.update_one({"_id": ObjectId(movie_id)}, {"$inc": {"added_count": 1}})
    # Check if the update was successful
    if result.modified_count > 0:
        print("Successfully incremented the added_count field.")
    else:
        print("No documents were updated.")

    return result


def update_movie_in_user_list(user_id: str, movie_id: str, watched: bool, favourite: bool):
    """
        Update a movie in the user list, changing his watched boolean.

        :param user_id: user id.
        :param movie_id: movie id.
        :param watched: if the movie is already watched or to watch.
        :return: result of the query
    """
    if favourite:
        watched = True

    result = db.user.update_one({"_id": ObjectId(user_id), "movies_list._id": ObjectId(movie_id)},
                                {"$set": {"movies_list.$.watched": watched, "movies_list.$.favourite": favourite}}
                                )

    # Check if the update was successful
    if result.modified_count > 0:
        print("Successfully updated the movie's watched status.")
    else:
        print("No documents were updated.")

    return result


def delete_movie_from_user_list(user_id: str, movie_id: str):
    """
        Delete a movie from the user list.

        :param user_id: user id.
        :param movie_id: movie id.
        :return: result of the query
    """
    result = db.user.update_one({"_id": ObjectId(user_id)},
                                {"$pull": {"movies_list": {"_id": ObjectId(movie_id)}}}
                                )

    # Check if the update was successful
    if result.modified_count > 0:
        print("Successfully removed the movie from the user's list.")
    else:
        print("No documents were updated.")

    return result


def get_movies_user_list(user_id: str, watched: bool):
    """
        Get all movies in the user list, based on watched boolean.

        :param user_id: user id.
        :param watched: if the movie is already watched or to watch.
        :return: movies to watch or movies watched
    """
    pipeline = [
        {"$match": {"_id": ObjectId(user_id)}},
        {"$project": {
            "movies_list": {
                "$filter": {
                    "input": "$movies_list",
                    "as": "movie",
                    "cond": {"$eq": ["$$movie.watched", watched]}
                }
            },
            "_id": 0
        }}
    ]

    result = list(db.user.aggregate(pipeline))

    return result[0]["movies_list"] if result else []


# USER QUERIES -- END

# REVIEW QUERIES -- START

def add_review(user_id: str, username: str, movie_id: str, title: str, content: str, date: datetime.datetime,
               vote: float):
    review = db.review.insert_one({
        "user": {
            "user_id": ObjectId(user_id),
            "username": username
        },
        "movie_id": ObjectId(movie_id),
        "title": title,
        "content": content,
        "date": date,
        "vote": vote
    })

    return review.inserted_id


def update_review(review_id: str, title: str, content: str, date: datetime.datetime, vote: float):
    result = db.review.update_one({"_id": ObjectId(review_id)}, {
        "$set": {
            "title": title,
            "content": content,
            "date": date,
            "vote": vote
        }
    })

    return result.modified_count > 0


# REVIEW QUERIES -- END


# TROUPE QUERIES -- START

def get_troupe(troupe_id: str):
    return db.troupe.find_one({"_id": ObjectId(troupe_id)})

# TROUPE QUERIES -- END
