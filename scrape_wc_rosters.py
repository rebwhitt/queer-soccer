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

    h3s =soup.find_all("h3")
    print(h3s)
    countries= []
    for h in h3s:
        countries.append(h.text)

    text = soup.find_all("table")
    print(text)
    # make empty list to hold all the data
    rows = []
    i=0
    for t in text:
        if len(t.find_all("tr"))>=18:
            print(countries[i])
            for row in t.find_all("tr"):
                # save cells in the row in array called "entries"
                entries = row.find_all(["td","th"])
                if(len(entries) > 5):
                    #print(entries)
                    # save selected values from each row in JSON format in list called "rows"
                    rows.append({
                        "Name": entries[2].text.strip(),
                        "Country": countries[i],
                        "Club": entries[6].text.strip()
                    })
            i+=1
    # then open the file based on the filename passed in
    fields = ["Name","Country","Club"]
    with open(filename, 'w', newline='', encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fields)
        writer.writeheader()

        # and write each row of data into the file
        for item in rows:
            writer.writerow(item)

    print(len(rows),"rows of data scraped and saved to",filename)
            
    #print(rows)

if __name__ == "__main__":
    for year in [2023]:
        url = f"https://en.wikipedia.org/wiki/{year}_FIFA_Women%27s_World_Cup_squads"
        filename = os.path.dirname(__file__)+f"\\Data\\Raw\\roster_wc{year}.csv"
        scrape_list(url, filename)
