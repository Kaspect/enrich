import java.io.File;
import java.io.BufferedWriter;
import org.apache.tika.parser.AutoDetectParser;
import org.apache.tika.sax.BodyContentHandler;
import java.io.FileInputStream;
import org.json.simple.JSONObject;
import org.apache.tika.parser.ParseContext;
import java.io.PrintWriter;
import java.io.FileWriter;
import org.xml.sax.SAXException;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import org.apache.tika.exception.TikaException;
import org.apache.tika.metadata.serialization.JsonMetadataSerializer;
import java.io.IOException;
import java.util.HashMap;
import org.apache.tika.metadata.Metadata;

public class QualityScore
{
	static int score;
    static int quality;
 	    
  public static void main(String[] args) throws TikaException, IOException
   {
         File data = new File("/Users/dhruvbhatia/Desktop/DhruvData");
         String[] names = data.list();
         HashMap<String, Integer> jsonMap = new HashMap<String, Integer>();
         for(String name : names)
         {
             if (new File("/Users/dhruvbhatia/Desktop/DhruvData/" + name).isDirectory())
             {
            	 
            	 File innerData = new File("/Users/dhruvbhatia/Desktop/DhruvData/" + name);
                    traverseData(innerData);
            	             	 jsonMap.put(name, score);
             }
         }
            
    		try(PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter("finalScores.json", true))))
 	     {
 	 	     
 	    	 JSONObject obj = new JSONObject();
 	    obj.putAll(jsonMap);
 	    out.printf( "%s",obj);
 
   	   }
 	catch (IOException e) {
   	}
         }
     
  public static void traverseData(File data) throws FileNotFoundException
    {
         System.out.println(data);
         
	     
         if (data.isDirectory())
         {
       	 File[] files = data.listFiles(); 
       	for (int i = 0; i < files.length; i++)
       	 {
       		  traverseData(new File(data, files[i].toString()));
       		  MetaParser(files[i]);
    	    
            }
         }
      }
	public static void MetaParser(File file) throws FileNotFoundException 
      {
   	      BodyContentHandler handler = new BodyContentHandler();
   	      Metadata metadata = new Metadata();
   	      FileInputStream inputstream = new FileInputStream(new File(file.toString()));
   	      ParseContext pcontext = new ParseContext();
   	      AutoDetectParser autoparser = new  AutoDetectParser();   	      
   	   try
   	   {
	      autoparser.parse(inputstream, handler, metadata,pcontext);
	   }
	      catch(Exception e) 
   	   { 
	    	  System.out.println("This is an error");
	    	  
	     }
	   
		System.out.println("Metadata Quality score");
	    String[] metadataFields = metadata.names();
	     int quality=2;
	     score=0;
 	      for(String name : metadataFields)
   	      {
 	    	if(name=="description"||name=="title"||name=="version")
  	    	 {
  	    		 quality=quality+1;
  	    	 }
 	    	if(name=="alias")
  	    	 {
  	    	 quality=quality+1;
  	    	 }
 	    	if (name.startsWith("dc:")||name.startsWith("cp:")||name.startsWith("xmp:")||name.startsWith("lom:")||name.startsWith("xmpTpg:")||name.startsWith("dcterms:"))
 	    	{
 	    		quality=quality+1;
 	    	} 	
 	    	if(name=="License")
   	    	{
   	    		quality=quality+1;
   	    	 } 
   	    	
 	    	 score=score+quality;
	    	 }
	    	
 	     
	
      }
}

   
   	   
   
