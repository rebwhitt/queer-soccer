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
    response = requests.get(url, verify=False, headers={'User-Agent':'rebeccabot'})
    print("scraping",url)
    soup = BeautifulSoup(response.content, 'html.parser')
    text = soup.find_all("table", "wikitable")
    
    # make empty list to hold all the data
    rows = []

    for t in text:
        if len(t.find_all("tr"))==5:
            for row in t.find_all("tr"):
                # save cells in the row in array called "entries"
                entries = row.find_all(["td","th"])
                if(len(entries) > 0):
                    #print(entries)
                    # save selected values from each row in JSON format in list called "rows"
                    rows.append({
                        "Pos": entries[0].text.strip(),
                        "Country": entries[1].text.strip(),
                        "Matches_Played": entries[2].text.strip(),
                        "Wins": entries[3].text.strip(),
                        "Draws": entries[4].text.strip(),
                        "Losses": entries[5].text.strip(),
                        "Goals For": entries[6].text.strip(),
                        "Goals Against": entries[7].text.strip(),
                        "Goal Differential": entries[8].text.strip(),
                        "Points": entries[9].text.strip()
                    })
    # then open the file based on the filename passed in
    fields = ["Pos","Country", "Matches_Played", "Wins", "Draws", "Losses",
                "Goals For", "Goals Against","Goal Differential", "Points"]
    with open(filename, 'w', newline='', encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fields)
        writer.writeheader()

        # and write each row of data into the file
        for item in rows:
            writer.writerow(item)

    print(len(rows),"rows of data scraped and saved to",filename)

if __name__ == "__main__":
    for year in [1991]:
        url = f"https://en.wikipedia.org/wiki/{year}_FIFA_Women%27s_World_Cup"
        filename = os.path.dirname(__file__)+f"\\Data\\Raw\\groupstage{year}.csv"
        scrape_list(url, filename)

    