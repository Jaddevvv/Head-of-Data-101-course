from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time
import pandas as pd

def get_imdb_top_movies():
    chrome_options = Options()
    # chrome_options.add_argument("--headless")  # Run in headless mode (optional)

    # Initialize the Chrome driver
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)

    url = "https://www.imdb.com/fr/chart/top/"
    driver.get(url)


    last_height = driver.execute_script("return document.body.scrollHeight")

    while True:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        
        time.sleep(2)
        
        new_height = driver.execute_script("return document.body.scrollHeight")
        
        if new_height == last_height:
            break
        last_height = new_height

    movies = []

    movie_list = driver.find_elements(By.CSS_SELECTOR, "ul[role='presentation'] li")


    for movie in movie_list:
        current_movie = {}
        try:
            splitted_values = movie.text.split("\n")
            print(splitted_values)
            current_movie["title"] = splitted_values[0]
            current_movie["year"] = splitted_values[1]
            current_movie["duration"] = splitted_values[2]
            current_movie["rating"] = splitted_values[4]
        except:
            continue

        movies.append(current_movie)
    
    return movies

def main():
    movies = get_imdb_top_movies()
    if movies:
        df = pd.DataFrame(movies)
        df.to_csv("../data/results/movies_selenium.csv", index=False)

if __name__ == "__main__":
    main()


