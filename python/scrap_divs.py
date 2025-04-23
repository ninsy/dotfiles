import requests
from bs4 import BeautifulSoup

divs = [
    "INTC",
    "T",
    "V",    
    "PFE",
    "NET",
    "CRSR"
]

headers = {
    "Accept-Language":"en-US,en;q=0.9",
    "Accept-Encoding":"gzip, deflate, br",
    "User-Agent":"Java-http-client/",
}

for ticker in divs:
    URL = f"https://www.nasdaq.com/market-activity/stocks/{ticker.lower()}/dividend-history"
    
    print("fetching page", URL)
    page = requests.get(URL, headers=headers)

    print("parsing content")
    soup = BeautifulSoup(page.content, "html.parser")

    print("Finding list...")
    div_rates = soup.find_all("ul", class_="dividend-history__summary")[0]
    
    div_rates.find()
