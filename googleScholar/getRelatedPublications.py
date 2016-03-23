import json
import sys
from pprint import pprint
import scholar
from scholar import SearchScholarQuery
from scholar import ScholarQuerier
from scholar import ScholarSettings


def getPublications(author):
	print author
	querier = ScholarQuerier()
	settings = ScholarSettings()
	querier.apply_settings(settings)
	query = SearchScholarQuery()
	query.set_author(author)
	querier.send_query(query)
	scholar.txt(querier, with_globals=False)

def main():
	if len(sys.argv) != 2:
		print "usage : python fetchRelatedPub.py file_author_names.json"
		return 0
	input_file = sys.argv[1];
	with open(input_file) as json_data:
		jsondict = json.load(json_data)
	for item in jsondict.items():
		filename 	= item[0]
		authors		= item[1]
		for author in authors:
			getPublications(author)

if __name__ == "__main__":
    sys.exit(main())
