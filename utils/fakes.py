import random
from faker import Faker

fake = Faker()

def generate_user_movie_list(movies, num_movies: int = 5):
    movie_list = []
    user_movies = random.sample(movies, num_movies)
    
    for user_movie in user_movies:
        user_movie["added_count"] = user_movie.get("added_count", 0) + 1
        watched = random.choice([True, False])
        if watched:  # Simulating user watching behavior
            user_movie["watched_count"] = user_movie.get("watched_count", 0) + 1
            
        movie = {
            "title": user_movie["title"],
            "poster": user_movie["poster"],
            "watched": watched
        }
        movie_list.append(movie)
    return movie_list

def generate_user(movies: list[dict], num_movies_per_user: int = 5, n: int = 200) -> list[dict]:
    users = []
    for _ in range(n):
        user = {
            "email": fake.email(),
            "password": fake.password(),
            "username": fake.user_name(),
            "moviesList": generate_user_movie_list(movies, num_movies_per_user)
        }
        users.append(user)
    return users 

def generate_reviews(usernames: list[str], movies: list[dict], n: int = 1000) -> list[dict]:
    reviews = []
    for _ in range(n):
        movie = random.choice(movies)
        vote = round(random.uniform(1, 5), 2)
        movie["vote_count"] = movie.get("vote_count", 0) + 1
        movie["vote_average"] = round((movie.get("vote_average", 0) + vote) / 2, 2)
        
        review = {
            "username": random.choice(usernames),
            "title": fake.sentence(),
            "content": fake.text(),
            "vote": vote,
            "date": fake.date_time_this_year()
        }
        
        if len(movie["reviews"]) >= 5:
            # Find the index to insert the review based on its date
            index_to_insert = 0
            for i, existing_review in enumerate(movie["reviews"]):
                if review["date"] > existing_review["date"]:
                    index_to_insert = i
                else:
                    break
            movie["reviews"].insert(index_to_insert, review)
            movie["reviews"] = movie["reviews"][:5]  # Truncate to keep only the most recent five reviews
        else:
            movie["reviews"].append(review)
    
        reviews.append(review)
    return reviews
