#-------------------------------------------------------------------------------
# Name:        generic_ner_parser.sh
#
# Purpose:     Call Tika to do NER parsing with Apache OpenNLP
#
# Prerequisite: (1) Build a runnable Tika standalone jar file 
#                   (see https://tika.apache.org/0.7/gettingstarted.html for how)
#               (2) Download all the trained NER library needed from Apache OpenNLP
#                   (see https://wiki.apache.org/tika/TikaAndNER for how)
#
# Usage: sh generic_ner_parser.sh &> ner.log
#
# Example Output:
#	PARSED_FILE: ie/ucd/libguides/AE5636AF4696FA63C4E20A2D18F999C9318C878E1651348F86A0DC3A5D1B0A7E
#	NER_DATE: Feb 13, 2015
#	NER_ORGANIZATION: Library Dos & Don'ts Dos Do
#	NER_ORGANIZATION: DO respect Library
#	NER_ORGANIZATION: UCD Library This
#	NER_ORGANIZATION: UCD Library
#	NER_ORGANIZATION: Student Library Welcome Welcome New Students Dos
#	NER_ORGANIZATION: PM URL:
#	NER_ORGANIZATION: UCD Library!
#	NER_ORGANIZATION: Our
#	NER_ORGANIZATION: 10:02
#	NER_ORGANIZATION: 2015
#	NER_ORGANIZATION: UCD Library Tutorials Need
#	NER_ORGANIZATION: Donts Guide Search Terms Search Welcome New Students
#	NER_PERSON: James Joyce Library Virtual Tour How
#	NER_PERSON: James Joyce Library
#	NER_PERSON: Jenny Collery
#
# Author:      Hang Guo
#
# Created:     3/29/2016
#-------------------------------------------------------------------------------


NER_RES=/users/hangguo/Tika/tika-ner-resources
PATH_PREFIX="$NER_RES/org/apache/tika/parser/ner/opennlp"
URL_PREFIX="http://opennlp.sourceforge.net/models-1.5"
TIKA_APP="/users/hangguo/Tika/tika-app/target/tika-app-1.12-SNAPSHOT.jar"
FILE_LIST=10k_sf_file_list
OUT=generic_ner_parsed.out

rm $OUT

while read  FN
do
FPATH='/nfs/lander/working/hangguo/polar_fulldump/'$FN

printf "PARSED_FILE:$FN\n" >> $OUT
java -classpath $NER_RES:$TIKA_APP org.apache.tika.cli.TikaCLI --config=tika-config.xml -m $FPATH | grep 'NER' >> $OUT
printf "\n" >> $OUT

done < $FILE_LIST
