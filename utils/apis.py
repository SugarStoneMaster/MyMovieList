import os 
import requests

from typing import Optional

from googleapiclient.discovery import build
from dotenv import load_dotenv

load_dotenv()

OMBD_API_KEY = os.getenv("OMDB_API_KEY")
GOOGLE_SEARCH_API_KEY = os.getenv("GOOGLE_SEARCH_API_KEY")
GOOGLE_CSE_ID = os.getenv("GOOGLE_CSE_ID")


# source: https://github.com/krishnasism/google-image-download/
def get_actor_photo_url(actor_name):
     #use google custom search to retrieve the first image the serach returns
    service = build("customsearch", "v1",
            developerKey=GOOGLE_SEARCH_API_KEY) # to use google custom search engine

    res = service.cse().list(
        q=actor_name, #query to be searched
        cx=GOOGLE_SEARCH_API_KEY, #custom search engine ID
        num=5, # no of images you want to download
        searchType='image', # type of file
        fileType='jpg', # extension
        safe='off', # not child friendly
    ).execute() # run this engine 

    for data in res['items']:
        return data['link']
    return None


def get_movie_cover(imdb_id=None, title=None, year=None) -> Optional[str]:
    if imdb_id:
        url = f"http://www.omdbapi.com/?i={imdb_id}&apikey={OMBD_API_KEY}"
    else:
        url = f"http://www.omdbapi.com/?t={title}&apikey={OMBD_API_KEY}&y={year}"

    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        if 'Poster' in data and data['Poster'] != 'N/A':
            return data['Poster']
        else:
            return "https://castlewoodassistedliving.com/wp-content/uploads/2021/01/image-coming-soon-placeholder.png"
    else:
        return "https://castlewoodassistedliving.com/wp-content/uploads/2021/01/image-coming-soon-placeholder.png"
        