import java.util.*;
import java.util.Map;
import java.text.SimpleDateFormat;
import org.codehaus.jackson.*;
import java.io.*;
import org.json.JSONObject;

public class CopyOftest {
	public static void main(String[] args) throws Exception {
		
		JsonFactory factory = new JsonFactory();
		JsonParser parser = factory.createJsonParser(new File("/var/tmp/zbxlist2.json"));
		while (parser.nextToken() != JsonToken.END_OBJECT) {
			String name = parser.getCurrentName();
			if(name != null) {
				if (name.equals("hosts")) {
					System.out.println("test1="+parser.getText());
					while (parser.nextToken() != JsonToken.END_OBJECT) {
						String name1 = parser.getCurrentName();
						if(name1 != null) {
							if (name1.equals("host")) {
								System.out.println("test10="+parser.getText());
							}
							
						}
					}
					
				}
				if (name.equals("comments")) {
					System.out.println("test2="+parser.getText());
				}
			
				else{
					parser.skipChildren();
				}
			}
		}
	}
}

		
		
	/*	
		
		if (parser.nextToken() == JsonToken.START_ARRAY) {
	    	while (parser.nextToken() != JsonToken.END_ARRAY) {
				if (parser.getCurrentToken() == JsonToken.START_OBJECT) {
	           	while (parser.nextToken() != JsonToken.END_OBJECT) {
	           		
						String name = parser.getCurrentName();
						parser.nextToken();
						if (name.equals("hosts")) {
				    		System.out.println("test1="+parser.getText());

						}
						if (name.equals("comments")) {
				    		System.out.println("test2="+parser.getText());
						}
						
						else{
							parser.skipChildren();
						}
						
	            	}
	            	
				}
				
	    	}
	    	

		}}}
		*/