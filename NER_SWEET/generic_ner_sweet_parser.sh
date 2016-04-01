#-------------------------------------------------------------------------------
# Name:        generic_ner_sweet_parser.sh
#
# Purpose:     Call Tika to do NER parsing with Apache OpenNLP. For each word in NER parsing results, 
#	       pick out all that are defined as concepts in SWEET ONTOLOGY. 
#
# Prerequisite: (1) Build a runnable Tika standalone jar file 
#                   (see https://tika.apache.org/0.7/gettingstarted.html for how)
#               (2) Download all the trained NER library needed from Apache OpenNLP
#                   (see https://wiki.apache.org/tika/TikaAndNER for how)
#		(3) Prepare tika-config.xml to enable NER parsing
#		(4) Download SWEET ONTOLOGY .owl files
#		    ( https://sweet.jpl.nasa.gov/)
#
# Usage: sh generic_ner_parser.sh &> ner.log
#
# Example Output:
#       
#       {"FILE_PATH":"edu/uci/research/www/725E7CAF744B79C68FC17D19EAD0BD40359A74DB16E62ACE55F3302596FFD1FD",
#       "SWEET_ONTOLOGY":[
#       "Animal",
#       "Cell",
#       "Compliance",
#       "Development",
#       "Human",
#       "Policy",
#       "Project",
#       "Research",
#       "State",
#       "Technology",
#       "Training"
#	]}
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
SWEET_DIR=/users/hangguo/sweet_2_3
OUT=generic_ner_sweet_parsed_out.json

rm $OUT

while read FN
do

	rm ner_word_list.tmp
	rm sweet_word_list.tmp
	rm sweet_out.tmp
	rm ner_word_list.tmp.sorted	
	rm sweet_word_list.tmp.sorted

	FPATH='/nfs/lander/working/hangguo/polar_fulldump/'$FN

	printf "{\"FILE_PATH\":\"$FN\",\n" >> $OUT

	java -classpath $NER_RES:$TIKA_APP org.apache.tika.cli.TikaCLI --config=tika-config.xml -m $FPATH | grep 'NER' | sed "s/NER.*://" |  sed 's/[^0-9a-zA-Z ]//g' | sed 's/^[[:space:]]*//' | sed -e 's/\s\+/\n/g' | sed '/^$/d' > ner_word_list.tmp

	while read word
	do
		grep -iwR "#$word" $SWEET_DIR | sed "s/.*comment.*//g" | sed "s/.*index\.html.*//" | grep "owl:Class rdf" | sed "s/.*\#//g" | sed "s/\".*//g" | sed "/^$/d" | sort | uniq >> sweet_word_list.tmp

	done < ner_word_list.tmp

	cat ner_word_list.tmp | sort | uniq > ner_word_list.tmp.sorted
	cat sweet_word_list.tmp | sort | uniq > sweet_word_list.tmp.sorted
	
	comm -12 ner_word_list.tmp.sorted sweet_word_list.tmp.sorted > sweet_out.tmp
	
	if [[ -s sweet_out.tmp ]] ; then
		printf "\"SWEET_ONTOLOGY\":[\n" >> $OUT
		cat sweet_out.tmp | sed "s/^/\"/" |  sed "s/$/\"/" | sed -e "$ ! s/$/,/" >> $OUT
		printf "]}\n" >> $OUT
	else
		printf "\"SWEET_ONTOLOGY\":null\n" >> $OUT
		printf "}\n" >> $OUT
	fi;
	printf "\n" >> $OUT

done < $FILE_LIST
