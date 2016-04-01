#-------------------------------------------------------------------------------
# Name:        geo_parser.sh
#
# Purpose:     Call Tika to extract geological information from file, look it up
#	       in a running Lucene Geo Gazetteer server and output the results
#
# Prerequisite: (1) Build a runnable Tika standalone jar file 
#	            (see https://tika.apache.org/0.7/gettingstarted.html for how)
#		(2) Installing the Lucene Gazetteer, make it running as server,
#		    installing and downloading an NER model and make a xml for 
#		    the application/geotopic MIME type.
#		    (see https://wiki.apache.org/tika/GeoTopicParser for how)
#
# Usage: sh geo_parser.sh &> geo.log
#
#
# Example Output:
#	Parsed File:107/4/150/128/37C721159B48CFB8B123B8EE2002D48451EA363112A9EBF53AFCB1B9B45FFDB8
#	Geographic_LATITUDE: 38.50038
#	Geographic_LONGITUDE: -80.50009
#	Geographic_NAME: West Virginia
#	Optional_LATITUDE1: 60.10867
#	Optional_LATITUDE2: 43.00024
#	Optional_LATITUDE3: 39.00027
#	Optional_LONGITUDE1: -113.64258
#	Optional_LONGITUDE2: -107.5009
#	Optional_LONGITUDE3: -105.50083
#	Optional_NAME1: Canada
#	Optional_NAME2: Wyoming
#	Optional_NAME3: Colorado
#
# Author:      Hang Guo
#
# Created:     3/19/2016
#-------------------------------------------------------------------------------

TIKA_JAR=/users/hangguo/Tika/tika-app/target/tika-app-1.12-SNAPSHOT.jar
NER_MODEL_DIR=/users/hangguo/src/location-ner-model
GEO_MIME_DIR=/users/hangguo/src/geotopic-mime
FILE_LIST=10k_sf_file_list
OUT=geo_parsed.json

rm $OUT

while read FN
 do 
	FPATH='/nfs/lander/working/hangguo/polar_fulldump/'$FN
	FPATH_GEOT=$FPATH'.geot'
	EXTRACTION_CMD='java -jar '$TIKA_JAR' -t '$FPATH' > '$FPATH_GEOT
	PARSING_CMD='java -classpath '$TIKA_JAR':'$NER_MODEL_DIR':'$GEO_MIME_DIR' org.apache.tika.cli.TikaCLI -m '$FPATH_GEOT

        printf "{\"FILE_PATH\":\"$FN\",\n" >> $OUT
        printf "\nFILE_PATH:$FN\n"
	eval $EXTRACTION_CMD
	eval $PARSING_CMD | grep 'Optional\|Geographic' > geo.tmp

	if [[ -s geo.tmp ]] ; then
        	printf "\"Geo_Info\":{\n" >> $OUT
		cat geo.tmp | sed "s/^/\"/" | sed "s/\: /\"\:\"/" | sed "s/$/\"/" | sed -e "$ ! s/$/,/" >> $OUT 
 	        printf "}}\n" >> $OUT
	else
		printf "\"Geo_Info\":null\n" >> $OUT
		printf "}\n" >> $OUT
	fi;
	printf "\n" >> $OUT

	rm $FPATH_GEOT
	rm geo.tmp
 
 done < $FILE_LIST
