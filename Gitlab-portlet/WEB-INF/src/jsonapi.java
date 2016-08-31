import java.io.*;
import java.net.*;

import sun.nio.cs.*;

import java.nio.charset.Charset;
import java.text.SimpleDateFormat;

import javax.portlet.PortletURL;
import javax.portlet.ResourceURL;

import java.util.*;
import java.util.regex.*;



public class jsonapi {
	public static String mg = "";
	 public static void main(String args[]) throws IOException {
		 int level=0;
		 api("","",level);
//		 System.out.println("MG="+mg);
		 
		 String strBefore1="\\[\\{";
		 String strAfter1="{";
		 String strBefore2="},$";
		 String strAfter2="}]";
		 mg = mg.replaceAll(strBefore1, strAfter1);
		 mg = mg.replaceAll(strBefore2, strAfter2);
		 mg = "["+mg;
		
		 mg = mg.replaceAll("},", "},\n");
//		 System.out.println("MG="+mg);
		 
//		 FileWriter fw_tmp = new FileWriter(lifepath +"/webapps/" + portname +"/git_tmp.json", false);
		 FileWriter fw_tmp = new FileWriter("/opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/webapps/test06-portlet/tree1.json");
		 PrintWriter pw_tmp = new PrintWriter(new BufferedWriter(fw_tmp));
		 pw_tmp.println(mg);
		 pw_tmp.close();
	 }
	 static String api(String path, String parent, int level) throws IOException {

		String giturl = "http://192.168.100.242",
				gitpjt = "1",
				gittoken = "_AS2JYyccyoqDcXWT2Mg";
		String tree = ".*(tree)+.*";

		
		URL apiUrl=new URL(giturl +"/api/v3/projects/"+ gitpjt +"/repository/tree?path="+path+"&reg=master&private_token="+ gittoken);
		String line,json="";
		BufferedReader reader = new BufferedReader(new InputStreamReader(apiUrl.openStream(), "UTF-8"));
		while((line = reader.readLine()) != null){
		    json+=line;
		}
		reader.close();
//		System.out.println("API="+json);
	
		String strBefore1="},";
		String strAfter1="},\n";
		json=json.replaceAll(strBefore1, strAfter1);
		String[] array = json.split("\n");
		for(int i=0; i< array.length; i++){
//			System.out.println(i+"="+array[i]);
//			String iddir = "";
			int index = array[i].indexOf("\"id\":\"");
			int index2 = array[i].indexOf("\",\"name\"");
			int index3 = array[i].indexOf("\",\"type\"");
//			iddir = array[i].substring(index+6, index2);

			if (array[i].matches(tree) ) {
				String dir;
				if(path == ""){
					dir = array[i].substring(index2+10, index3);
				}
				else{
					dir = path+"/"+array[i].substring(index2+10, index3);
				}
//				System.out.println("DIR="+array[i]);
				System.out.println("path="+path);
				String strBefore2="},|}]";
				String strAfter2=",\"fullpath\":\"\",\"level\":"+level+",\"parent\":\""+parent+"\",\"isLeaf\":\"false\",\"expanded\":\"true\",\"loaded\":\"true\"},";
				array[i]=array[i].replaceAll(strBefore2, strAfter2);
				mg = mg+array[i];
//				return dir;
//				System.out.println("LEVEL="+level);
				parent = array[i].substring(index+6, index2);
//				System.out.println("PARENT="+parent);
				api(dir,parent,level+1);
			}
			else{
				String filename =array[i].substring(index2+10, index3);
				String strBefore2="},|}]";
				if(level == 0){
					String strAfter2=",\"fullpath\":\""+filename+"\",\"level\":"+level+",\"parent\":\"\",\"isLeaf\":\"true\",\"expanded\":\"true\",\"loaded\":\"true\"},";
					array[i]=array[i].replaceAll(strBefore2, strAfter2);
				}
				else{
					String strAfter2=",\"fullpath\":\""+path+"/"+filename+"\",\"level\":"+level+",\"parent\":\""+parent+"\",\"isLeaf\":\"true\",\"expanded\":\"true\",\"loaded\":\"true\"},";
					array[i]=array[i].replaceAll(strBefore2, strAfter2);
					System.out.println(filename);
					System.out.println(array[i]);
				}
				
				mg = mg+array[i];
			}
//			return path;
			
		}
		return "";
	   }
}
