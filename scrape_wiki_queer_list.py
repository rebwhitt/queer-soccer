from bs4 import BeautifulSoup
import requests
import csv
import os

def scrape_list(url, filename):
    # get and load the webpage as the variable "soup" from the above url
    response = requests.get(url, verify=False, headers={'User-Agent':'rebeccabot'})
    print("scraping",url)
    soup = BeautifulSoup(response.content, 'html.parser')

    names =soup.find_all("ul")

    # make empty list to hold all the data
    rows = []

    for n in names:
        for i in n.find_all("li"):
            rows.append({"Name":i.text})
    
     # then open the file based on the filename passed in
    fields = ["Name"]
    with open(filename, 'w', newline='', encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fields)
        writer.writeheader()

        # and write each row of data into the file
        for item in rows:
            writer.writerow(item)

    print(len(rows),"rows of data scraped and saved to",filename)


if __name__ == "__main__":
    for year in [2023]:
        url = "https://en.wikipedia.org/wiki/List_of_LGBTQ_women%27s_association_footballers"
        filename = os.path.dirname(__file__)+f"\\Data\\Raw\\queerlist_wiki.csv"
        scrape_list(url, filename)
