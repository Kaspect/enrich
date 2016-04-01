#-------------------------------------------------------------------------------
# Name:        geo_parser.sh
#
# Purpose:     Call Tika to extract geological information from file, look it up
#	       in a running Lucene Geo Gazetteer server and output the results in json format
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
#
#	{"FILE_PATH":"edu/berkeley/vcresearch/159A0874BBB0E6F1FFEFB2481B7C50B394F4ACAFDC169A1E0F1425D002F944E7",
#	"Geo_Info":{
#	"Geographic_LATITUDE":"39.46407",
#	"Geographic_LONGITUDE":"-78.02754",
#	"Geographic_NAME":"Berkeley County"
#	}}
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
