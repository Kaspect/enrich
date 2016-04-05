/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package edu.usc.ir.visualization;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;

import javax.ws.rs.core.MediaType;
import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.tika.Tika;
import org.apache.tika.config.TikaConfig;
import org.apache.tika.exception.TikaException;
import org.apache.tika.metadata.Metadata;
import org.apache.tika.parser.ner.NamedEntityParser;
import org.apache.tika.parser.ner.nltk.NLTKNERecogniser;
import org.xml.sax.SAXException;

import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class NLTKandCoreNLP {
    
	private HashSet<String> freq; 
    private HashMap<String, Integer> nltk;
    private HashMap<String, Integer> nlp;
    private JsonNode datasetElement;
    private Tika tika;
    private Metadata md;
    private ObjectMapper mapper;
    
    public NLTKandCoreNLP() {
    	
    	freq = new HashSet<String>();
     	nltk = new HashMap<String,Integer>();
  		nlp = new HashMap<String,Integer>();
  		tika = null;
  		datasetElement=null;
        mapper = new ObjectMapper();
  		System.setProperty(NamedEntityParser.SYS_PROP_NER_IMPL, NLTKNERecogniser.class.getName());
  		try {
			tika = new Tika(new TikaConfig(NLTKandCoreNLP.class.getResourceAsStream("tika-config.xml")));
		} catch (TikaException | IOException | SAXException e) {
			System.out.println("Could not load Tika");
			e.printStackTrace();
		}
    }
    
    public static void main(String m[]) throws JsonParseException, JsonMappingException, IOException {
        
        String memexUrl = m[0];
        String username = m[1];
        String password = m[2];
        File destination =new File(m[3]);
        NLTKandCoreNLP obj = new NLTKandCoreNLP();
        obj.countNER(memexUrl, username, password);
        obj.createJSON(destination);
        
    }
    
    private void countNER(String memexUrl, String username, String password) throws JsonParseException, JsonMappingException, IOException {

    	JsonNode node;
        JsonNode dataset=null;
        String url;
        String response;
        
        for (int c=0; c<101; c+=100) {
        	
            url = memexUrl + "/select?q=gunsamerica&start="+c+"&rows=100&fl=content%2Corganizations%2Cpersons%2Cdates%2Clocations&wt=json&indent=true";
            response = WebClient
            		   .create(url, username, password, null)
            		   .accept(MediaType.APPLICATION_JSON)
            		   .get()
            		   .readEntity(String.class);

            try {
                node = mapper.readTree(response);
                dataset= node.get("response").get("docs");
            } catch (JsonProcessingException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
            
            Iterator<JsonNode> datasetElements = dataset.iterator();
            
            while (datasetElements.hasNext()) {
                datasetElement = datasetElements.next();
                String content = datasetElement.get("content").asText();
                md = new Metadata();
                try (InputStream stream = new ByteArrayInputStream(content.getBytes(StandardCharsets.UTF_8))) {
                    tika.parse(stream, md);
                } catch (IOException e) {
                	e.printStackTrace();
                }
                
                if(datasetElement.has("locations")) {
                	extract("locations");
                }
                
                if(datasetElement.has("dates")) {
                	extract("organizations");
                }

                if(datasetElement.has("organizations")) {
                    extract("organizations");
                }
                
                if(datasetElement.has("persons")) {
                	extract("persons");
                }
                
                if(md.getValues("NER_NAMES").length > 0) {
                    for(String ner_name: Arrays.asList(md.getValues("NER_NAMES"))) {
                        if(!freq.contains(ner_name)) {
                            freq.add(ner_name);
                        }
                        if(nltk.containsKey(ner_name)) {
                            nltk.put(ner_name, nltk.get(ner_name) + 1);
                        }
                        else {
                            nltk.put(ner_name, 1);
                        }
                    }
                }
            }
        }
    }
    
    private void extract(String ner) throws JsonParseException, JsonMappingException, IOException {
    	String names[]=null;
        names= mapper.readValue(datasetElement.get(ner).toString(),String[].class);
        for(int i=0; i<names.length; i++) {
            if(!freq.contains(names[i])) {
                freq.add(names[i]);
            }
            if(nlp.containsKey(names[i])) {
                nlp.put(names[i], nlp.get(names[i]) + 1);
            } else {
                nlp.put(names[i], 1);
            }
        }
    }

	private void createJSON(File destination) throws JsonGenerationException, JsonMappingException, IOException {
		ArrayList<Names> frequencies = new ArrayList<Names>();
        for (String value:freq) {
            int x = nltk.containsKey(value)?nltk.get(value):0;
            int y = nlp.containsKey(value)?nlp.get(value):0;
            int z = x+y-Math.abs(x-y);
            if (z==0) {
            	z = x>y?0:-y;
            }
            frequencies.add(new Names(value, z ));
        }
        
        Collections.sort(frequencies, maximumOverlap);
        ArrayList<String> final_labels = new ArrayList<String>();
        ArrayList<Integer> nltk_value = new ArrayList<Integer>();
        ArrayList<Integer> nlp_value = new ArrayList<Integer>();
        for (int i=0; i<frequencies.size(); i++) {
            String value = frequencies.get(i).name;
            final_labels.add(value);
            if (nltk.containsKey(value)) {
                nltk_value.add(nltk.get(value));
            } else {
                nltk_value.add(0);
            }
            if (nlp.containsKey(value)) {
                nlp_value.add(nlp.get(value));
            } else {
                nlp_value.add(0);
            }
        }

        Series []s = {new Series("nltk", nltk_value),new Series("nlp", nlp_value)};
        Labels labels = new Labels(final_labels, s);
        ObjectMapper mapper = new ObjectMapper();
        destination = new File(destination.getAbsolutePath() + "/nltk_vs_corenlp.json");
        mapper.writerWithDefaultPrettyPrinter().writeValue(destination, labels);
        System.out.println("Json ready for Visualization: " + destination.getAbsolutePath());
	}

	public static Comparator<Names> maximumOverlap = new Comparator<Names>() {
        public int compare(Names one, Names two) {
            return (int)two.strength - (int)one.strength;
        }
    };

}
