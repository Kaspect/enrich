import sys

curl 'http://localhost:8983/solr/update/json?commit=true' --data-binary @books.json -H 'Content-type:application/json'
