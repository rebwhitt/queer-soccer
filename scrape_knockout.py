from bs4 import BeautifulSoup
import requests
import re
import csv
import os

def scrape_list(url, filename):
    # get and load the webpage as the variable "soup" from the above url
    response = requests.get(url, verify=False, headers={'User-Agent':'rebeccabot'})
    print("scraping",url)
    soup = BeautifulSoup(response.content, 'html.parser')

    h3s =soup.find_all(["h3","table"])
    #print(h3s)

    countries= []
    stage=""
    for h in h3s:
        if(h.text in ["Quarter-finals", "Quarterfinals"]):
            stage="Quarter-finals"
        if(h.text in ["Semi-finals", "Semifinals"]):
            stage="Semi-finals"
        if(h.text in ["Third place play-off", "Third place playoff", "Third-place match"]):
            stage=h.text
        if(stage in ["Quarter-finals","Semi-finals"]):
            for th in h.find_all("th"):
                #print(re.search("[0-9]+",th.text))
                if (re.search("([0-9]+|Penalties)",th.text))==None:
                    print(stage,th.text.strip())
                    countries.append({"Stage":stage,
                              "Country":th.text.strip()})

    # then open the file based on the filename passed in
    fields = ["Stage","Country"]
    with open(filename, 'w', newline='', encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fields)
        writer.writeheader()

        # and write each row of data into the file
        for item in countries:
            writer.writerow(item)

    print(len(countries),"rows of data scraped and saved to",filename)
            

if __name__ == "__main__":
    for year in [2023]:
        url = f"https://en.wikipedia.org/wiki/{year}_FIFA_Women%27s_World_Cup#Knockout_stage"
        filename = os.path.dirname(__file__)+f"\\Data\\Raw\\knockout_wc{year}.csv"
        scrape_list(url, filename)
