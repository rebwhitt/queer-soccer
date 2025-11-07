from bs4 import BeautifulSoup
import requests
import re
import csv
import os

countries = ["Argentina",
            "Australia",
            "Brazil",
            "Canada",
            "China",
            "Colombia",
            "Costa Rica",
            "Denmark",
            "England",
            "France",
            "Germany",
            "Haiti",
            "Italy",
            "Jamaica",
            "Japan",
            "Korea Republic",
            "Morocco",
            "Netherlands",
            "New Zealand",
            "Nigeria",
            "Norway",
            "Panama",
            "Philippines",
            "Portugal",
            "Ireland",
            "Rep. of Ireland",
            "Republic of Ireland",
            "South Africa",
            "Spain",
            "Sweden",
            "Switzerland",
            "United States",
            "Vietnam",
            "Zambia"
            ]

def is_country(name):
    return name in countries

def scrape_list(url, filename):
    # get and load the webpage as the variable "soup" from the above url
    response = requests.get(url, verify=False)
    soup = BeautifulSoup(response.content, 'html.parser')
    text = soup.find("div","entry-content").text
    text = re.split("\n+\s*", text)

    # make empty list to hold all the data
    rows = []

    country=""
    for t in text:
        if is_country(t):
            country=t
            #print(country,"----")
        elif not ("post " in t or "Photo" in t or "AF+" in t or "No gays" in t or "GROUP" in t) and len(t)<100:
            name=t
            #print(name, country)
            rows.append({"Name":name, "Country":country})

    # then open the file based on the filename passed in
    fields = ["Name", "Country"]
    with open(filename, 'w', newline='', encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fields)
        writer.writeheader()

        # and write each row of data into the file
        for item in rows:
            writer.writerow(item)

    print(len(rows),"rows of data scraped and saved to",filename)

if __name__ == "__main__":
    url = "https://www.autostraddle.com/2023-world-cup-gay-players/"
    filename = os.path.dirname(__file__)+"\\Data\\Raw\\queerlist2023.csv"
    scrape_list(url, filename)