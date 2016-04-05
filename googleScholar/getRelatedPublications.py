import json
import sys
import scholar
from scholar import ScholarSettings
from scholar import ScholarQuerier
from scholar import SearchScholarQuery

def getRelatedPublications(author):
    print author
    settings = ScholarSettings() #adjust scholar settings
    querier = ScholarQuerier() #Instance of ScholarQuerier() conducts a search on Google Scholar
    querier.apply_settings(settings) #applies settings as provided by the instance of ScholarSettings()
    query = SearchScholarQuery()
    query.set_author(author)
    querier.send_query(query)
    print querier.articles

def read():
    file = '/Users/dhruvbhatia/Documents/enrich/googleScholar/extractedContent.json';
    with open(file) as data:
        jsondata = json.load(data)
    for item in jsondata:
        filename  = item['file']
        author = item['name1']
        getRelatedPublications(author)

if __name__ == '__main__':
        read()
