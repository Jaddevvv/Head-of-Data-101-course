from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time
import pandas as pd

chrome_options = Options()
# chrome_options.add_argument("--headless")  # Run in headless mode (optional)

# Initialize the Chrome driver
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)

url = "https://www.sunsetcosmeticos.com.br/p/marcas"
driver.get(url)

brand_table = driver.find_element(By.CSS_SELECTOR, "section.section-list")
all_brands = brand_table.find_elements(By.CSS_SELECTOR, "a.anchor")

brand_urls = [brand.get_attribute("href") for brand in all_brands]

def scroll_to_bottom(driver):
    # scroll until its not scrolling anymore
    last_height = driver.execute_script("return document.body.scrollHeight")
    while True:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(1)
        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            break
        last_height = new_height


def get_rating(product):
    rating = 0
    stars = product.find_elements(By.TAG_NAME,"svg")
    for star in stars:
        if star.get_attribute("class") == "icon -fill":
            rating += 1
    return rating

all_products = []
for brand_url in brand_urls:
    driver.get(brand_url)
    time.sleep(2)   

    scroll_to_bottom(driver)
    product_table = driver.find_elements(By.CSS_SELECTOR, "div.products > div")
    for product in product_table:
        product_details = {}
        products_text_split = product.text.split("\n")
        if len(products_text_split) == 5:
            products_text_split = [products_text_split[0]] + products_text_split[2::]
        elif len(products_text_split) == 6:
            #remove item at position 3
            products_text_split = [products_text_split[1]] + products_text_split[3::]
        elif len(products_text_split) == 7:
            products_text_split = [products_text_split[1]] +  [products_text_split[3]] + products_text_split[5::]
            print("[POS AT 7 DEBUG]" + str(products_text_split))
        elif len(products_text_split) != 4:
            print("[DEBUG] " + str(products_text_split))
        elif len(products_text_split) <= 1:
            continue

        
        product_details["brand"] =products_text_split[0].split("-")[-1].strip()
        product_details["name"] = products_text_split[0]
        product_details["price"] = products_text_split[1]
        product_details["rating"] = str(get_rating(product)) + "/5"
        all_products.append(product_details)
    


df = pd.DataFrame(all_products)
df.to_csv("sunset_cosmeticos.csv", index=False)




