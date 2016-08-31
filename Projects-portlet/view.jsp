<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui"%>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet"%>
<%@ taglib uri="http://liferay.com/tld/security" prefix="liferay-security"%>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme"%>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui"%>
<%@ taglib uri="http://liferay.com/tld/util" prefix="liferay-util"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %>
<%@ page import="java.io.*" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.net.*" %>
<%@ page import="sun.nio.cs.*" %>
<%@ page import="java.nio.charset.Charset" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="javax.portlet.PortletURL"%>
<%@ page import="javax.portlet.ResourceURL"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.regex.*"%>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONException" %>
<%@ page import="com.goebl.david.Webb" %>
<%@ page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONException" %>
<%@ page import="com.goebl.david.Webb" %>
<%@ page import="org.codehaus.jackson.*" %>
<portlet:defineObjects />
 <%!
String dir = "/opt/liferay/config/";
String git_cfg = "portlet_config";
String  gitpjname,gitpjtid = "";
String [] val = new String[10];
String lifepath="",cnf;
String giturl = "";
String gittoken = "";
String gitusr = "";
String flserver = "";
String jos = "";
%>
<input type="button" value="更新" onclick="refresh()" >
<input type="button" value="Apply" onclick="applay()">
<input type="button" value="Destroy" onclick="destroy()">
<table border="1">
<tr BgColor="#ffffd5">
<!-- 
	<td align="center">プロジェクトID</td><td align="center">プロジェクト名</td><td align="center">Applay</td><td align="center">Destroy</td>
 -->
 	<td align="center">プロジェクトID</td><td align="center">プロジェクト名</td><td align="center">選択</td>
</tr>

<%

//GitLab,JOS情報の取得
BufferedReader in = new BufferedReader(new FileReader(dir + git_cfg));
while (true) {
	String s = in.readLine();
	if (s == null) {
		break;
	}
	int index = s.indexOf("=");
	if (s.matches("^GitURL=.*")){
		giturl = s.substring(index+1);
	}
	else if (s.matches("^PrivateToken=.*")){
		gittoken = s.substring(index+1);
	}
	else if (s.matches("^GitUser=.*")){
		gitusr = s.substring(index+1);
	}
	else if (s.matches("^Liferay_Tomcat_Path=.*")){
		lifepath = s.substring(index+1);
	}
	else if (s.matches("^JobSchedulerURL=.*")){
		jos = s.substring(index+1);
	}
}	
in.close();


URL apiUrl=new URL(giturl +"/api/v3/projects/?private_token="+ gittoken);
HttpURLConnection huc =  (HttpURLConnection)  apiUrl.openConnection(); 
huc.setRequestMethod("GET"); 
huc.connect(); 
//System.out.println("="+huc.getResponseCode());
if (huc.getResponseCode() == 200){
	String line,json="";
	BufferedReader reader = new BufferedReader(new InputStreamReader(apiUrl.openStream(), "UTF-8"));
	while((line = reader.readLine()) != null){
    	json+=line;
	}
	reader.close();

//System.out.println("json="+json);

	JsonFactory factory = new JsonFactory();
	JsonParser parser = factory.createJsonParser(json);
	String pid = "";
	String tag = "";
	if (parser.nextToken() == JsonToken.START_ARRAY) {
		while (parser.nextToken() != JsonToken.END_ARRAY) {
			if (parser.getCurrentToken() == JsonToken.START_OBJECT) {
       		while (parser.nextToken() != JsonToken.END_OBJECT) {
					String name = parser.getCurrentName();
					parser.nextToken();
					String cr = "#FFFFFF";
					if (name.equals("id")) {
						pid = parser.getText();
//					out.print("</td><td>");
//					out.print("<td align=\"center\"></td>");
			    		out.print("<td align=\"right\">"+parser.getText()+"</td>");
		   	 		out.print( "&nbsp;&nbsp;&nbsp" );
					}
					if (name.equals("name")) {
						tag = parser.getText();
						PortletURL actionURL = renderResponse.createActionURL();
						actionURL.setParameter("name", tag);
						actionURL.setParameter("id", pid);
					//System.out.println("TAG=" + tag);
//					out.print("</td><td>");
//					out.print("<a href='" + actionURL.toString() + "'target='_self'>" + tag + "</a>");
						out.print("<td align=\"center\"><a href='" + actionURL.toString() + "'target='_self'>" + tag + "</a></td>");
						out.print( "&nbsp;&nbsp;&nbsp" );
						out.print("<td> <input type=radio name=jobapi value="+tag+ "> </td>");
					}
					else{
						parser.skipChildren();
					}
        		}

     	  	out.print("<tr>");
			}
		}
	}
}
%>
</table>
</body>
</html>

<script>
function refresh(){
  location.reload();
}

function applay() {
	var xhr = new XMLHttpRequest();
	var jos = "<%= jos %>";
	var test = document.getElementsByName("jobapi");
	var pj;
	var name = "sfj/sfj_apply";
	
	for(i=0; i<test.length; i++){
		if(test[i].checked){
		pj = test[i].value;
		}
	}
//	console.log("1="+pj);
	
	if(pj != undefined){
		if (window.confirm("プロジェクト：" +pj+"をApplayしますか？")) {
			xhr.open("POST", jos, true);
			xhr.onreadystatechange = function() {
				if (xhr.readyState == 4) {
					alert("JOBを実行します ");

				}
				else {
					alert("JOBを実行できません");
				}
			};
			xhr.send("<add_order job_chain='"+name+"'> <params><param name='PNAME' value='"+pj+"'/></params></add_order>");
			return true;
		}
		else{
			return false;
		}
	}
	else{
		alert("プロジェクトを指定してください。");
		return false;
	}
}


function destroy() {
	var dxhr = new XMLHttpRequest();
	var djos = "<%= jos %>";
	var dtest = document.getElementsByName("jobapi");
	var dpj;
	var dname = "sfj/sfj_destroy";
	
	for(j=0; j<dtest.length; j++){
		if(dtest[j].checked){
		dpj = dtest[j].value;
		}
	}
	
	if(dpj != undefined){
		if (window.confirm("プロジェクト：" +dpj+"をDestroyしますか？")) {
			dxhr.open("POST", djos, true);
			dxhr.onreadystatechange = function() {
				if (dxhr.readyState == 4) {
					alert("JOBを実行します ");
				}
				else {
					alert("JOBを実行できません");
				}
			};
			dxhr.send("<add_order job_chain='"+dname+"'> <params><param name='PNAME' value='"+dpj+"'/></params></add_order>");
			return true;
		}
		else{
			return false;
		}
	}
	else{
		alert("プロジェクトを指定してください。");
		return false;
	}
}


</script>