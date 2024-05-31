import pandas as pd
from utils.connection import open_connection, close_connection, get_db_name


def main():
    client = open_connection()
    db_name = get_db_name()
    
    if db_name is None:
        raise ValueError("DB_NAME is not set in .env file")
    
    # this should predispose the creation of a database in MongoDB
    # the actual creation will be postponed until data is inserted
    db = getattr(client, db_name)
    
    # create Movie collection
    movieColl = db.movie
    # create Rating collection
    ratingColl = db.rating
    # create User collection and the validation schema which ensures that each user document will have the same structure
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
                    "description": "'password' must be a string of at least 8 characters, and is required"
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
    
    close_connection(client)


if __name__ == "__main__":
    main()
