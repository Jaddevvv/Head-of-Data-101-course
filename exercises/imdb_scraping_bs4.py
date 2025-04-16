import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

def get_imdb_top_movies():
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }

    url = "https://www.imdb.com/chart/top/"
    
    try:
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.text, 'html.parser')

        movie_list = soup.select('ul[role="presentation"] li')
        
        movies = []
        
        for movie in movie_list:
            try:
                movie_text = movie.get_text(separator="\n").strip()
                splitted_values = movie_text.split("\n")
                
                current_movie = {
                    "title": splitted_values[0],
                    "year": splitted_values[1],
                    "duration": splitted_values[2],
                    "rating": splitted_values[4]
                }
                
                movies.append(current_movie)
                
            except Exception as e:
                print(f"Error processing movie: {e}")
                continue
        
        return movies
        
    except requests.RequestException as e:
        # Catch errors
        print(f"Error fetching data: {e}")
        return []

def main():
    movies = get_imdb_top_movies()
    
    if movies:
        df = pd.DataFrame(movies)
        df.to_csv("../data/results/movies_bs4.csv", index=False)


if __name__ == "__main__":
    main() 