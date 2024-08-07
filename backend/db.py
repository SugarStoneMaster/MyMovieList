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


class Singleton(dict):
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(Singleton, cls).__new__(cls)
        return cls._instance


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

default_projection = {"_id": 1, "title": 1, "poster": 1, "release_year": 1, "popularity": 1, "vote_average": 1}

APPROXIMATION_COUNT = 10
movie_review_count = Singleton()
movie_added_count = Singleton()
movie_watched_count = Singleton()


def paginate_query(collection, query_dict, projection, offset: int, limit: int, sort=None):
    """
        Paginate a MongoDB query.

        :param collection: The collection from which you want to paginate.
        :param query_dict: The MongoDB query.
        :param projection: The fields to include or exclude in the result.
        :param offset: The number of documents to skip.
        :param limit: The maximum number of documents to return.
        :param sort: The sort order for the query.
        :return: A tuple containing the paginated results and the total count of documents.
    """
    query = collection.find(query_dict, projection)

    if sort:
        query = query.sort(sort)

    total_count = collection.count_documents(query_dict)
    results = query.skip(offset).limit(limit)

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

            # Construct $or conditions for title, directors, and cast with $regex for partial and full name matching
            or_conditions = [{"title": {"$regex": text.strip(), "$options": "i"}}]

            # For directors and cast matching
            director_or_conditions = []
            actors_or_conditions = []

            for term in text_list:
                term = term.strip()
                if len(term) > 0:
                    director_or_conditions.append({"directors.full_name": {"$regex": term.strip(), "$options": "i"}})
                    actors_or_conditions.append({"actors.full_name": {"$regex": term.strip(), "$options": "i"}})

            # Add $in conditions if there are multiple terms
            if len(director_or_conditions) > 1:
                or_conditions.append({"$or": director_or_conditions})
            else:
                or_conditions.extend(director_or_conditions)

            if len(actors_or_conditions) > 1:
                or_conditions.append({"$or": actors_or_conditions})
            else:
                or_conditions.extend(actors_or_conditions)

            query["$or"] = or_conditions

        projection = projection or default_projection

        # Paginate the query

        return paginate_query(db.movie, query, projection, offset, items_per_page)
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

        projection = projection or default_projection

        # Paginate the query
        return paginate_query(db.movie, query, projection, offset, items_per_page)
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
        projection = projection or default_projection

        # Paginate the query
        return paginate_query(db.movie, query, projection, offset, items_per_page)
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
        projection = projection or default_projection

        # Paginate the query
        return paginate_query(db.movie, {}, projection, offset, items_per_page, {field: int(order)})
    except Exception as e:
        return e


def get_movie_reviews(offset: int, items_per_page: int = None, movie_id: str = None) -> Union[
    Tuple[List[dict], int], Exception]:
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
        query = {"movie_id": ObjectId(movie_id)}

        # Paginate the query
        return paginate_query(db.review, query, {}, offset, items_per_page, {"date": -1})
    except Exception as e:
        return e


def get_movie(movie_id: str):
    return db.movie.find_one({"_id": ObjectId(movie_id)})


# MOVIES QUERIES -- END


# USER QUERIES -- START

def apple_sign_in(email, username):
    user = db.user.find_one({"email": email})

    if user:
        return user
    else:
        new_user = {
            "username": username,
            "email": email,
            "password": "defaultpassword",  # You might want to generate a secure password or handle this appropriately
            "movies_list": []
        }
        result = db.user.insert_one(new_user)
        new_user["_id"] = result.inserted_id
        print(new_user)
        return new_user


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


def get_movies_user_list(user_id: str, watched: bool, favourite: bool):
    """
        Get all movies in the user list, based on watched boolean.

        :param user_id: user id.
        :param watched: if the movie is already watched or to watch.
        :param favourite: if the movie is favourite or not. Favourite can be true only if watched is true
        :return: movies to watch or movies watched
    """
    if not watched:
        favourite = False

    pipeline = [
        {"$match": {"_id": ObjectId(user_id)}},
        {"$project": {
            "movies_list": {
                "$filter": {
                    "input": "$movies_list",
                    "as": "movie",
                    "cond": {
                        "$and": [
                            {"$eq": ["$$movie.watched", watched]},
                            {"$eq": ["$$movie.favourite", favourite]}
                        ]
                    }
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

    if review.inserted_id:
        # update movie
        review_document = db.review.find_one({"_id": ObjectId(review.inserted_id)})
        movie_document = db.movie.find_one({"_id": ObjectId(movie_id)}, {"reviews": 1})
        movie_reviews = []

        if movie_document:
            movie_reviews = movie_document["reviews"]

            if len(movie_reviews) > 0:
                movie_reviews = sorted(movie_reviews, key=lambda x: x["date"])
                movie_reviews.pop(0)

        movie_reviews.append(review_document)
        movie_reviews = sorted(movie_reviews, key=lambda x: x["date"], reverse=True)
        db.movie.update_one({"_id": ObjectId(movie_id)}, {"$set": {"reviews": movie_reviews}})

        if movie_id in movie_review_count:
            movie_review_count[movie_id] += 1

            if movie_review_count[movie_id] >= 5:
                update_movie_review_stats(movie_id)
        else:
            movie_review_count[movie_id] = 1

    return review.inserted_id


def update_review(review_id: str, title: str, content: str, vote: float):
    review = db.review.find_one({"_id": ObjectId(review_id)})

    if not review:
        return False  # Return False if the review does not exist

    # Update the review document in the review collection
    result = db.review.update_one(
        {"_id": ObjectId(review_id)},
        {
            "$set": {
                "title": title,
                "content": content,
                "vote": vote
            }
        }
    )

    if review["movie_id"] in movie_review_count:
        movie_review_count[review["movie_id"]] += 1

        if movie_review_count[review["movie_id"]] >= 5:
            update_movie_review_stats(review["movie_id"])
    else:
        movie_review_count[review["movie_id"]] = 1

    # Find the movie document and update the specific review inside the reviews array
    movie = db.movie.find_one({"_id": ObjectId(review["movie_id"])}, {"reviews": 1})
    if movie:
        movie_reviews = movie.get("reviews", [])

        # Find the index of the review in the movie's reviews array
        review_index = next((index for (index, d) in enumerate(movie_reviews) if d["_id"] == ObjectId(review_id)), None)

        if review_index is not None:
            # Update the specific review in the reviews array
            movie_reviews[review_index]["title"] = title
            movie_reviews[review_index]["content"] = content
            movie_reviews[review_index]["vote"] = vote

            # Update the movie document with the modified reviews array
            db.movie.update_one(
                {"_id": ObjectId(review["movie_id"])},
                {"$set": {"reviews": movie_reviews}}
            )

    return result.modified_count > 0

def update_movie_review_stats(movie_id: str):
    pipeline = [
        {"$match": {"movie_id": ObjectId(movie_id)}},
        {"$group": {
            "_id": "$movie_id",
            "vote_average": {"$avg": "$vote"},
            "vote_count": {"$sum": 1}
        }}
    ]

    result = list(db.review.aggregate(pipeline))

    if result:
        average_vote = result[0]["vote_average"]
        vote_count = result[0]["vote_count"]
    else:
        average_vote = 0  # Handle the case where there are no reviews
        vote_count = 0

    # Update the movie document with the vote count and average vote
    db.movie.update_one(
        {"_id": ObjectId(movie_id)},
        {"$set": {"vote_average": round(average_vote, 2), "vote_count": vote_count}}
    )

    movie_review_count[movie_id] = 0


def update_movie_added_count(movie_id: str):
    result = list(db.user.find({"movies_list._id": ObjectId(movie_id)}))

    db.movie.update_one({"_id": ObjectId(movie_id)}, {"$set": {"added_count": len(result)}})
    movie_added_count[movie_id] = 0


def update_movie_watched_count(movie_id: str):
    result = list(db.user.find({"movies_list.watched": True}))

    db.movie.update_one({"_id": ObjectId(movie_id)}, {"$set": {"watched_count": len(result)}})
    movie_watched_count[movie_id] = 0


# REVIEW QUERIES -- END


# TROUPE QUERIES -- START

def get_troupe(troupe_id: str):
    return db.troupe.find_one({"_id": ObjectId(troupe_id)})

# TROUPE QUERIES -- END
