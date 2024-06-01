import os 
import pandas as pd
import requests 
from tqdm import tqdm
from utils.connection import open_connection, close_connection, get_db_name
from dotenv import load_dotenv
load_dotenv()


def get_movie_cover(api_key, imdb_id=None, title=None, year=None):
    if imdb_id:
        url = f"http://www.omdbapi.com/?i={imdb_id}&apikey={api_key}"
    else:
        url = f"http://www.omdbapi.com/?t={title}&apikey={api_key}&y={year}"
      
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        if 'Poster' in data and data['Poster'] != 'N/A':
            return data['Poster']
        else:
            return "Cover not available"
    else:
        return "Error fetching data"


def insert_movies(movieColl, data):
    movies = []
    columns = list(data.columns)
    api_key = os.getenv("OMDB_API_KEY")
    
    for idx, movieRow in tqdm(data.iterrows(), desc="Collecting movie entries...", total=1000):
        # consider only 1000 movies (OMDB API has a limit of 1000 requests per day)
        if idx == 1000:
            break
    
        movie = {}
        for column in columns:
            value = movieRow[column]
            
            # get the movie's poster using OMDb API
            if column == "imdb_id":
                # if the imbd_id is not available, search the movie by its title and release year
                if pd.isna(value):
                    cover_url = get_movie_cover(api_key=api_key, title=movieRow["title"], year=movieRow["release_date"].split("-")[-1])
                else: 
                    cover_url = get_movie_cover(api_key=api_key, imdb_id=value)  
                movie["cover_url"] = cover_url
    
            # handle NaN values (empty columns)
            if pd.isna(value):
                value = None

            if column not in ["cast", "genres", "production_companies", "production_countries", "spoken_languages", 
                                "director", "director_of_photography", "writers", "producers", "music_composer"]:
                movie[column] = value
            else:
                if value is None:
                    movie[column] = []
                else:
                    movie[column] = value.split(",")
        
        # add the ratings field --> SUBSET PATTERN
        movie["ratings"] = []
        movies.append(movie)
    
    result = movieColl.insert_many(movies)
    
    return result.inserted_ids

def pre_process_data(data_path: str):
    # read the data from the csv file
    data = pd.read_csv(data_path)
    
    # drop the duplicates
    data = data.drop_duplicates(subset=["id"])
    data = data.drop(columns=["id"])
    
    # return the preprocessed data
    return data


def main():
    client = open_connection()
    db_name = get_db_name()
    
    if db_name is None:
        raise ValueError("DB_NAME is not set in .env file")
    
    # this should predispose the creation of a database in MongoDB
    # the actual creation will be postponed until data is inserted
    db = getattr(client, db_name)
    
     # MOVIE - RATING: SUBSET DESIGN PATTERN
     # source: https://www.mongodb.com/blog/post/building-with-patterns-the-subset-pattern
     # for the movie and rating collections, we will use the subset design pattern
     # the subset design pattern is a design pattern that allows us to store a subset of the data in a collection    
     # in this case, we store the 5 most recent ratings for each movie in the Movie collection and all the ratings in the Rating collection
     
     # RATING - USER: EXTENDED REFERENCE DESIGN PATTERN
     # source: https://www.mongodb.com/blog/post/building-with-patterns-the-extended-reference-pattern
     # for the rating and user collections, we will use the extended reference design pattern
     # instead of embedding the user data in the rating document, or use the id of the user to perform a join operation,
     # we will store the embed the most accessed user data in the rating document and perform join operations only when needed
    
    # create Movie collection
    movieColl = db.movie
    # # create Rating collection
    ratingColl = db.rating
    
    # # create User collection and the validation schema which ensures that each user document will have the same structure
    userColl = db.create_collection("user", validator={
        "$jsonSchema": {
            "bsonType": "object",
            "required": ["name", "last_name", "username", "email", "password"],
            "properties": {
                "_id": {  # allows the insertion of other documents
                    "bsonType": "objectId"
                },
                "name": {
                    "bsonType": "string",
                    "maxLength": 25,
                    "description": "'name' must be a string and is required. Max 25 characters"
                },
                "last_name": {
                    "bsonType": "string",
                    "maxLength": 25,
                    "description": "'last_name' must be a string and is required. Max 25 characters"
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
                    "description": "'password' must be a string of at least 8 characters and maximum 16 characters, and is required"
                },
                "myMovieList": {
                    "bsonType": "array",
                    "description": "'myMovieList' must be an array of movie objects",
                    "items": {
                        "bsonType": "object",
                        "required": ["movieTitle", "watched"],
                        "properties": {
                            "movieTitle": {
                                "bsonType": "string",
                                "description": "'movieTitle' must be a string and is required"
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
    
    data = pre_process_data("TMDB_all_movies.csv")
    insert_movies(movieColl, data)
    
    close_connection(client)


if __name__ == "__main__":
    main()
