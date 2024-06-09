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


def get_movies(title: Optional[str] = None, directors: Optional[Union[str, list[str]]] = None, 
    actors: Optional[Union[str, list[str]]] = None):
    
    if directors and isinstance(directors, str):
        directors = [directors]
        
    if actors and isinstance(actors, str):
        actors = [actors]
    
    query = {}
    
    if title:
        query["title"] = title
    
    if directors:
        query["directors"] = {"$in": directors}
    
    if actors:
        query["cast"] = {"$in": actors}
    
    try:
        return list(db.movie.find(query))
    except Exception as e:
        return e
        

def get_movies_by_genres(genres: Union[list[str], str]):
    """
    Finds and returns movies by genres.
    """
    
    if isinstance(genres, str):
        genres = [genres]
        
    try:
        return list(db.movie.find({"genres": {"$all": genres}}))
    except Exception as e:
        return e


def get_movies_by_release_year(release_year: int):
    """
    Finds and returns movies by release year.
    """
        
    try:
        return list(db.movie.find({"release_year": release_year}))
    except Exception as e:
        return e