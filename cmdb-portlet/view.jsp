<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet"%>
<%@ page import="java.io.*"%>
<%@ page import="java.lang.*"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONException"%>
<%@ page import="com.goebl.david.Webb"%>
<%@ page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@ page import="java.net.*"%>
<%@ page import="sun.nio.cs.*"%>
<%@ page import="java.nio.charset.Charset"%>
<%@ page import="org.codehaus.jackson.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.regex.Pattern"%>
<%@page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@page import="java.util.Map"%>
<%@page import="net.sf.json.*"%>

<portlet:defineObjects />

<%!
String dir = "/opt/liferay/config/";
String cmdb_cfg = "portlet_config";
String desc = "";
String auth = "";
String cmhost = "";
String cmtop = "";
String cmur = "";
String cmpw = "";
String event = "";
String mg = "";
String code,model,description,num,type,purchase,room,id,ip,state,health,video,date,notes,ram,cpu,assignee,speed,size,supplier,cost;
//String evhost ="";
%>


<%
//CMDBuildサーバ情報の取得
BufferedReader in = new BufferedReader(new FileReader(dir + cmdb_cfg));
int j=0;
while (true) {
	String s = in.readLine();
	if (s == null) {
		break;
	}
	int index = s.indexOf("=");
	if (s.matches("^CMDBuildURL=.*")){
		cmhost = s.substring(index+1);
		cmtop = s.substring(index+1)+"/cmdbuild";
	}
	else if (s.matches("^CMDBUser=.*")){
		cmur = s.substring(index+1);
	}
	else if (s.matches("^CMDBPassword=.*")){
		cmpw = s.substring(index+1);
	}
}
in.close();

%>

<a target="_blank" href=<%= cmtop %>><img
	src="<%=request.getContextPath()%>/img/cmdbuild_logo.png" /></a>


<input type="button" value="カード情報" onClick="kakunin()" style="position: relative; left: 0px; top: -20px;" />

<br>
<br>

<table border="1">

<%
	//evhost = ParamUtil.getString(request, "myname");
//System.out.println("EV1="+evhost);
// CMDBuild 認証
URL authurl = new URL(cmhost +"/cmdbuild/services/rest/v1/sessions/");
HttpURLConnection connection = null;
connection = (HttpURLConnection) authurl.openConnection();
connection.setDoOutput(true);
connection.setRequestMethod("POST");
connection.setRequestProperty("Content-Type","application/json");
BufferedWriter writer = new BufferedWriter(
		new OutputStreamWriter(connection.getOutputStream()));
writer.write("{\"username\": \"" +cmur+ "\",\"password\":\""+cmpw+"\"}");
writer.flush();
if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
	InputStreamReader isr = new InputStreamReader(
	connection.getInputStream());
	BufferedReader reader = new BufferedReader(isr);
	String line;
	while ((line = reader.readLine()) != null) {
		int index = line.indexOf(",\"_id\":\"");
		int index2 = line.indexOf("\"}}");
		auth = line.substring(index + 8, index2);
	}
} else {
	System.out.println(connection.getResponseCode());
}
//System.out.println(auth);

// Card情報取得
URL eventurl = new URL(cmhost +"/cmdbuild/services/rest/v1/classes/PC/cards");
HttpURLConnection connection_event = null;
connection_event = (HttpURLConnection) eventurl.openConnection();
connection_event.setDoOutput(true);
connection_event.setRequestMethod("GET");
connection_event.setRequestProperty("Content-Type","application/json");
connection_event.setRequestProperty("CMDBuild-Authorization",auth);
if (connection_event.getResponseCode() == HttpURLConnection.HTTP_OK) {
	InputStreamReader isr = new InputStreamReader(
	connection_event.getInputStream());
	BufferedReader reader_event = new BufferedReader(isr);
	String line_event;
	while ((line_event = reader_event.readLine()) != null) {
		String strBefore3="\\{\"data\":";
		String strBefore4=",\"meta\":.*";
		String strAfter3="";
		line_event = line_event.replaceAll(strBefore3,strAfter3);
		line_event = line_event.replaceAll(strBefore4,strAfter3);
		event = line_event;
	}
} else {
	System.out.println(connection.getResponseCode());
}
//System.out.println("EVENT="+event);
	
	mg = "";
	JsonFactory factory = new JsonFactory();
	//String hos="localhost";
	//イベントリストを画面表示
	//JsonParser parser = factory.createJsonParser(new File("/var/tmp/cmdbuild2.json"));
	JsonParser parser = factory.createJsonParser(event);
	if (parser.nextToken() == JsonToken.START_ARRAY) {
		while (parser.nextToken() != JsonToken.END_ARRAY) {
			if (parser.getCurrentToken() == JsonToken.START_OBJECT) {
				while (parser.nextToken() != JsonToken.END_OBJECT) {
					String name = parser.getCurrentName();
					parser.nextToken();
					if ("Code".equals(name)) {
						//code = name+": "+parser.getText()+"<br>";
						code = "<tr><td>Code</td><td>" + parser.getText() + "</td></tr>";
					}

					if ("Model".equals(name)) {
						//model = name+": "+parser.getText()+"<br>";
						model = "<tr><td>Model</td><td>" + parser.getText() + "</td></tr>";
					}

					if ("Description".equals(name)) {
						//description = name+": "+parser.getText()+"<br>";
						description = "<tr><td>Description</td><td>" + parser.getText() + "</td></tr>";
					}

					if ("SerialNumber".equals(name)) {
						//num = name+": "+parser.getText()+"<br>";
						num = "<tr><td>SerialNumber</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("_type".equals(name)) {
						//type = name+": "+parser.getText()+"<br>";
						type = "<tr><td>Type</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("PurchaseDate".equals(name)) {
						//purchase = name+": "+parser.getText()+"<br>";
						purchase = "<tr><td>PurchaseDate</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("Room".equals(name)) {
						//room = name+": "+parser.getText()+"<br>";
						room = "<tr><td>Room</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("_id".equals(name)) {
						//id = name+": "+parser.getText()+"<br>";
						id = "<tr><td>Id</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("IPAddress".equals(name)) {
						//ip = name+": "+parser.getText()+"<br>";
						ip = "<tr><td>IPAddress</td><td>" + parser.getText() + "</td></tr>";
					}
					/*
					if ("AssetState".equals(name)) {
						//state = name+": "+parser.getText()+"<br>";
						state = "<tr><td>AssetState</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("Assethealth".equals(name)) {
						//health = name+": "+parser.getText()+"<br>";
						health = "<tr><td>Assethealth</td><td>" + parser.getText() + "</td></tr>";
					}
					*/
					if ("VideoCard".equals(name)) {
						//video = name+": "+parser.getText()+"<br>";
						video = "<tr><td>VideoCard</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("AcceptanceDate".equals(name)) {
						//date = name+": "+parser.getText()+"<br>";
						date = "<tr><td>AcceptanceDate</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("AcceptanceNotes".equals(name)) {
						//notes = name+": "+parser.getText()+"<br>";
						notes = "<tr><td>AcceptanceNotes</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("RAM".equals(name)) {
						//ram = name+": "+parser.getText()+"<br>";
						ram = "<tr><td>RAM</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("CPUNumber".equals(name)) {
						//cpu = name+": "+parser.getText()+"<br>";
						cpu = "<tr><td>CPUNumber</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("Assignee".equals(name)) {
						//assignee = name+": "+parser.getText()+"<br>";
						assignee = "<tr><td>Assignee</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("CPUSpeed".equals(name)) {
						//speed = name+": "+parser.getText()+"<br>";
						speed = "<tr><td>CPUSpeed</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("HDSize".equals(name)) {
						//size = name+": "+parser.getText()+"<br>";
						size = "<tr><td>HDSize</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("Supplier".equals(name)) {
						//supplier = name+": "+parser.getText()+"<br>";
						supplier = "<tr><td>Supplier</td><td>" + parser.getText() + "</td></tr>";
					}
					if ("FinalCost".equals(name)) {
						//cost = name+": "+parser.getText()+"<br>";
						cost = "<tr><td>FinalCost</td><td>" + parser.getText() + "</td></tr>";
					}

					else {
						parser.skipChildren();
					}
				}
				mg = mg + code + model + description + num + type
						+ purchase + room + id + ip 
						+ video + date + notes + cpu + assignee + speed
						+ size + supplier + cost + "\n";
			}
		}
	}
	//System.out.println(mg);
	String[] array = mg.split("\n");
	for (int i = 0; i < array.length; i++) {
		//int index1 = array[i].indexOf("code: ");
		int index1 = array[i].indexOf("<tr><td>Code</td><td>");
		//int index2 = array[i].indexOf("<br>");
		int index2 = array[i].indexOf("</td></tr>");
		//int index2 = array[i].indexOf("&nbsp");

		String evhost = ParamUtil.getString(request, "myname");
		String card;
		//card = array[i].substring(index1+7, index2);
		card = array[i].substring(index1 + 21, index2);
		//System.out.println("EVHOST=" + evhost);
		//System.out.println("CARD=" + card);
		//if (evhost == card){
		if (card.matches(evhost)) {
			out.print(array[i]);
			desc = card;
		}
	}
%>
</table>



<script type="text/javascript">

function kakunin(){
	var desc = "<%= desc %>";
	var cmtop = "<%= cmtop %>";
	if ( desc != "null"){
		window.open(cmtop+"/management.jsp#classes/PC/cards/Code~"+desc);
	}
	else{
		window.open(cmtop+"/management.jsp#classes/PC/cards/");
	}

	//System.out.println("desc2="+desc);
}

</script>