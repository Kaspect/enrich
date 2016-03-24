import json
import sys
import scholar
from scholar import ScholarSettings
from scholar import ScholarQuerier
from scholar import SearchScholarQuery
from pprint import pprint

def getRelatedPublications(author):
	print author
    settings = ScholarSettings() #adjust scholar settings
	querier = ScholarQuerier() #Instance of ScholarQuerier() conducts a search on Google Scholar
	querier.apply_settings(settings) #applies settings as provided by the instance of ScholarSettings()
	query = SearchScholarQuery()
	query.set_author(author)
	querier.send_query(query)
	scholar.txt(querier, with_globals=False)

def read():
	if len(sys.argv) != 2:
		return 0
	file = sys.argv[1];
	with open(file) as data:
		jsondata = json.load(data)
	for item in jsondata.items():
		filename 	= item[0]
		author		= item[1]
		for value in author:
			getRelatedPublications(value)
