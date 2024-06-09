import os
import pandas as pd

from typing import Optional
from datetime import datetime

from tqdm.notebook import tqdm
from utils.connection import open_connection, close_connection, get_db_name
from utils.apis import get_movie_cover, get_actor_photo_url
from utils.fakes import generate_user, generate_reviews

from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, OperationFailure
    

def get_movies_and_troupe(data) -> tuple[list, list]:
    movies = []
    troupe = {}

    for idx, movieRow in tqdm(data.iterrows(), desc="Collecting movie entries...", total=data.shape[0]):
        movie = {}
     
        movie["title"] = movieRow["title"]
        movie["vote_average"] = round(movieRow["vote_average"], 2)
        movie["vote_count"] = movieRow["vote_count"]
        movie["release_date"] = datetime.strptime(movieRow["release_date"], "%Y-%m-%d").isoformat()
        movie["release_year"] = movieRow["release_year"]
        movie["overview"] = movieRow["overview"]
        movie["runtime"] = movieRow["runtime"]
        movie["budget"] = movieRow["budget"]
        movie["revenue"] = movieRow["revenue"]
        movie["popularity"] = movieRow["popularity"]
        movie["poster"] = get_movie_cover(imdb_id=movieRow["imdb_id"])
        movie["genres"] = movieRow["genres"].split(", ")
        movie["production_companies"] = movieRow["production_companies"].split(", ")
        movie["production_countries"] = movieRow["production_countries"].split(", ")
        movie["spoken_languages"] = movieRow["spoken_languages"].split(", ")
        
        for column in ["cast", "director"]:
            members = []
                
            for member in movieRow[column].split(", "):      
                members.append({
                    "full_name": member,
                })
                troupe_movie = {
                    "title": movieRow["title"],
                    "poster": movie["poster"], 
                    "release_year": movieRow["release_year"],
                }
                if member not in troupe:
                    troupe[member] = {
                        "type": "actor" if column == "cast" else "director",
                        "movies": [troupe_movie]                    }
                else: 
                    troupe[member]["movies"].append(troupe_movie)
        
            movie["actors" if column == "cast" else "directors"] = members 
        
        # add the reviews field --> SUBSET PATTERN
        movie["reviews"] = []
        movie["watched_count"] = 0
        movie["added_count"] = 0
        
        movies.append(movie)
    
    troupe_data = []
    
    for full_name, data in troupe.items():
        troupe_data.append({
            "full_name": full_name,
            "type": data["type"],
            "movies": data["movies"],
            "picture": "https://media-cldnry.s-nbcnews.com/image/upload/t_fit-760w,f_auto,q_auto:best/rockcms/2023-09/kevin-james-king-of-queens-zz-230927-368fe6.jpg"
        })
    
    return movies, troupe_data


def pre_process_data(data_path: str) -> pd.DataFrame:
    # read the data from the csv file
    data = pd.read_csv(data_path)

    # drop the duplicates
    data = data.drop_duplicates(subset=["id"])
    data = data.drop(columns=["writers", "producers", "music_composer", "director_of_photography"])
    # remove rows with NA values
    clean_data = data.dropna()
    # add release_year
    clean_data.loc[:, 'release_year'] = clean_data['release_date'].str.slice(0, 4)
    # convert 'release_year' to numeric type if needed
    clean_data.loc[:, 'release_year'] = pd.to_numeric(clean_data['release_year'], errors='coerce', downcast='integer')
    # consider only the movies released in the last 30 years
    clean_data = clean_data.loc[(clean_data['release_year'] >= 1995) & (clean_data['release_year'] <= 2025)]
    clean_data.reset_index(drop=True, inplace=True)
    
    # return the preprocessed data
    return clean_data


def main():
    client = open_connection()
    db_name = get_db_name()

    if db_name is None:
        raise ValueError("DB_NAME is not set in .env file")

    # this should predispose the creation of a database in MongoDB
    # the actual creation will be postponed until data is inserted
    db = getattr(client, db_name)

    # MOVIE - RATING: SUBSET DESIGN PATTERN source:
    # https://www.mongodb.com/blog/post/building-with-patterns-the-subset-pattern for the movie and rating
    # collections, we will use the subset design pattern the subset design pattern is a design pattern that allows us
    # to store a subset of the data in a collection in this case, we store the 5 most recent ratings for each movie
    # in the Movie collection and all the ratings in the Rating collection

    # USER - MOVIE: SUBSET DESIGN PATTERN
    # we will use the subset design pattern for the user's watchlist

    # RATING - USER: EXTENDED REFERENCE DESIGN PATTERN source:
    # https://www.mongodb.com/blog/post/building-with-patterns-the-extended-reference-pattern for the rating and user
    # collections, we will use the extended reference design pattern instead of embedding the user data in the rating
    # document, or use the id of the user to perform a join operation, we will store the embed the most accessed user
    # data in the rating document and perform join operations only when needed

    # create Movie collection
    movieColl = db["movie"]
    # create Rating collection
    reviewColl = db["review"]
    # create Troupe collection 
    troupeColl = db["troupe"]
    
    # create User collection. The validation schema ensures that each user document will have the same
    # structure
    if "user" not in db.list_collection_names():
        userColl = db.create_collection("user", validator={
            "$jsonSchema": {
                "bsonType": "object",
                "required": ["username", "email", "password"],
                "properties": {
                    "_id": {  # allows the insertion of other documents
                        "bsonType": "objectId"
                    },
                    "username": {
                        "bsonType": "string",
                        "maxLength": 20,
                        "description": "'username' must be a string and is required. Max 20 characters"
                    },
                    "email": {
                        "bsonType": "string",
                        "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
                        "description": "'email' must be a string and match the regular expression pattern"
                    },
                    "password": {
                        "bsonType": "string",
                        "minLength": 8,
                        "maxLength": 16,
                        "description": "'password' must be a string of at least 8 characters and maximum 16 characters, "
                                    "and is required"
                    },
                    "moviesList": {
                        "bsonType": "array",
                        "description": "'moviesList' must be an array of movie objects",
                        "items": {
                            "bsonType": "object",
                            "required": ["title", "watched"],
                            "properties": {
                                "title": {
                                    "bsonType": "string",
                                    "description": "'movieTitle' must be a string and is required"
                                },
                                "poster": {
                                    "bsonType": ["string", "null"],
                                    "maxLength": 2048,
                                    "description": "'poster' is the url of the movie poster"
                                },
                                "watched": {
                                    "bsonType": "bool",
                                    "description": "'watched' must be a boolean and is required"
                                }
                            }
                        }
                    }
                }
            }
        })
    else:
        userColl = db["user"]

    data = pre_process_data("TMDB_all_movies.csv")
    movies, troupe_data = get_movies_and_troupe(data)
    print(len(movies))
    users = generate_user(movies=movies)
    reviews = generate_reviews(movies=movies, usernames=[user["username"] for user in users])

    moviesIds = movieColl.insert_many(movies)
    
    if len(moviesIds.inserted_ids) == 0:
        close_connection(client)
        raise ValueError("No movies were inserted")
    
    troupeIds = troupeColl.insert_many(troupe_data)
    
    if troupeIds.inserted_ids == 0:
        movieColl.delete_many({})
        close_connection(client)
        raise ValueError("No troupe data was inserted")
    
    usersIds = userColl.insert_many(users)
    
    if usersIds.inserted_ids == 0:
        troupeColl.delete_many({})
        movieColl.delete_many({})
        close_connection(client)
        raise ValueError("No user was inserted")
    
    reviewIds = reviewColl.insert_many(reviews)
    
    if reviewIds.inserted_ids == 0:
        userColl.delete_many({})
        troupeColl.delete_many({})
        movieColl.delete_many({})
        close_connection(client)
        raise ValueError("No review was inserted")
    
    print(f"Inserted {len(moviesIds.inserted_ids)} movies\nInserted {len(troupeIds.inserted_ids)} troupe data\n" + 
        f"Inserted {len(usersIds.inserted_ids)} users\nInserted {len(reviewIds.inserted_ids)} reviews")
    close_connection(client)


if __name__ == "__main__":
    main()
