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