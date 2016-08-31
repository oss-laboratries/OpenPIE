<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@ page import="java.io.*"%>
<%@ page import="java.lang.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONException"%>
<%@ page import="com.goebl.david.Webb"%>
<%@ page import="java.net.*"%>
<%@ page import="sun.nio.cs.*"%>
<%@ page import="java.nio.charset.Charset"%>
<%@ page import="org.codehaus.jackson.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui"%>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet"%>
<%@page import="javax.portlet.PortletURL"%>
<%@page import="javax.portlet.ResourceURL"%>
<%@page import="java.util.*"%>
<%@page import="javax.portlet.ActionRequest"%>
<%@page import="javax.portlet.ActionResponse"%>
<%@page import="javax.portlet.ActionResponse"%>
<%@page import="javax.portlet.PortletException"%>
<%@page import="javax.portlet.ProcessAction"%>
<%@page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@page import="com.liferay.util.bridges.mvc.MVCPortlet"%>
<%@page import="javax.portlet.RenderResponse"%>


<portlet:defineObjects />
<%!
public static String dir = "/opt/liferay/config/";
	public static String zbx_cfg = "portlet_config";
	public static String auth = "";
	public static String event = "";
	public static String mg = "";
	public static String hostname = "";
	public static String zbxtop, zbxhost, zbxur, zbxpw,zbxsrn,zbx;
	public static String host = "";
	public static String time = "";
	public static String description = "";
	public static String priority = "";
	public static String comment = "";
	%>

<%!
public static String main(String test) throws IOException {
		//Zabbixサーバ情報の取得
		BufferedReader in = new BufferedReader(new FileReader(dir + zbx_cfg));
		int j = 0;
		while (true) {
			String s = in.readLine();
			if (s == null) {
				break;
			}
			int index = s.indexOf("=");
			if (s.matches("^ZabbixURL=.*")) {
				zbxhost = s.substring(index + 1) + "/api_jsonrpc.php";
				zbx = s.substring(index + 1);
			} else if (s.matches("^ZabbixUser=.*")) {
				zbxur = s.substring(index + 1);
			} else if (s.matches("^ZabbixPassword=.*")) {
				zbxpw = s.substring(index + 1);
			}
		}
		in.close();
		zbxtop = zbx + "/index.php?name="+zbxur+"&password="+zbxpw+"&enter=Sign%20in";
		zbxsrn = zbx + "/screens.php";
		//System.out.println("TOP="+zbxtop);
		
		URL url = new URL(zbxhost + "/api_jsonrpc.php");
		HttpURLConnection connection = null;
		connection = (HttpURLConnection) url.openConnection();
		connection.setDoOutput(true);
		connection.setRequestMethod("POST");
		connection.setRequestProperty("Content-Type", "application/json-rpc");
		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(
				connection.getOutputStream()));
		writer.write("{\n" + "    \"jsonrpc\": \"2.0\",\n"
				+ "    \"method\": \"user.login\",\n" 
				+ "    \"params\": {\n"
				+ "        \"user\": \"" 
				+ zbxur + "\",\n"
				+ "        \"password\": \"" 
				+ zbxpw + "\"\n" + "    },\n"
				+ "    \"id\": 1,\n" 
				+ "    \"auth\": null\n" 
				+ "}");
		writer.flush();
		if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
			InputStreamReader isr = new InputStreamReader(
					connection.getInputStream());
			BufferedReader reader = new BufferedReader(isr);
			String line;
			while ((line = reader.readLine()) != null) {
				//System.out.println(line);
				int index = line.indexOf("\",\"result\"");
				int index2 = line.indexOf("\",\"id\":");
				auth = line.substring(index + 12, index2);

			}
		} else {
			System.out.println(connection.getResponseCode());
			return "";
		}
		//System.out.println("auth=" + auth);

		//zabbixイベント情報取得
		URL urlevent = new URL(zbxhost + "/api_jsonrpc.php");
		HttpURLConnection connection_event = null;
		connection_event = (HttpURLConnection) urlevent.openConnection();
		connection_event.setDoOutput(true);
		connection_event.setRequestMethod("POST");
		connection_event.setRequestProperty("Content-Type",
				"application/json-rpc");
		BufferedWriter writer_event = new BufferedWriter(
				new OutputStreamWriter(connection_event.getOutputStream()));
		writer_event.write("{\n" + "    \"jsonrpc\": \"2.0\",\n"
				+ "    \"method\": \"trigger.get\",\n" 
				+ "    \"id\": \"1\",\n"
				+ "    \"auth\": \"" + auth + "\",\n" 
				+ "    \"params\": {\n"
				+ "        \"expandData\": \"1\",\n"
				+ "        \"output\": \"extend\",\n"
				+ "        \"sortfield\": \"lastchange\",\n"
				+ "        \"sortorder\": \"DESC\",\n"
				+ "		 \"selectHosts\": \"extend\",\n"
				+ "				\"filter\": { \"value\": \"1\"}\n" 
				+ "    }\n" + "}");
		writer_event.flush();
		if (connection_event.getResponseCode() == HttpURLConnection.HTTP_OK) {
			InputStreamReader isr = new InputStreamReader(
					connection_event.getInputStream());
			BufferedReader reader_event = new BufferedReader(isr);
			String line_event;
			while ((line_event = reader_event.readLine()) != null) {
				//System.out.println(line_event);
				event = line_event;
			}
		} else {
			System.out.println(connection.getResponseCode());
		}

		//String strBefore1="\\{\"id\":\"1\",\"result\":";
		String strBefore1 = "\\{\"jsonrpc\":\"2.0\",\"result\":";
		String strBefore2 = ",\"id\":\"1\"}";
		String strAfter = "";
		event = event.replaceAll(strBefore1, strAfter);
		event = event.replaceAll(strBefore2, strAfter);

		String strBefore3 = "},";
		String strAfter2 = "}]\n[";
		event = event.replaceAll(strBefore3, strAfter2);
		String[] array = event.split("\n");

		//System.out.println("event=" + event);

		//イベントリストを画面表示
		for (int i = 0; i < array.length; i++) {
			//System.out.println(i +array[i]);
			JsonFactory factory = new JsonFactory();
			JsonParser parser = factory.createJsonParser(array[i]);
			if (parser.nextToken() == JsonToken.START_ARRAY) {
				while (parser.nextToken() != JsonToken.END_ARRAY) {
					if (parser.getCurrentToken() == JsonToken.START_OBJECT) {
						host = "";
						while (parser.nextToken() != JsonToken.END_OBJECT) {
							String name = parser.getCurrentName();
							parser.nextToken();
							String cr = "#FFFFFF";

							if (name.equals("host")) {
								host = "HOST="+parser.getText();;
							}
							if (host.matches("")) {
								if (name.equals("hosts")) {
									hostname = sub(parser.getCurrentName(),array[i]);
									String tag = hostname;
									host = "HOST="+hostname;
								}
							}

							if (name.equals("lastchange")) {
								//lastchangeをyyyy/MM/dd HH:mm:ss表示に整形
								String format = "yyyy/MM/dd HH:mm:ss";
								SimpleDateFormat simpleDateFormat = new SimpleDateFormat(format);
								long t = parser.getValueAsLong();
								Date nowTime = new Date(t * 1000L);
								format = simpleDateFormat.format(nowTime);
								//time = "</td><td>" + format + "&nbsp;&nbsp;&nbsp";
								time = "	TIME="+format;

							}

							if (name.equals("description")) {
								//description = "</td><td>" + parser.getText()+ "&nbsp;&nbsp;&nbsp";
								description = "	DESCRIPTION="+parser.getText();

							}

							if (name.equals("priority")) {
								priority = "	PRIORITY="+parser.getText();

							}

							if (name.equals("comments")) {
								comment = "</td><td>" + parser.getText() + "&nbsp;&nbsp;&nbsp";
								comment = "	COMMENT="+parser.getText();
							} 
							else {
								parser.skipChildren();
							}
						}
						////out.print("<tr>");
						//mg = mg + host + time + description + priority + comment + "<tr>";
						mg = mg + host + time + description + priority + comment +"\n";
					}
				}
			}

		}
		return mg;
	}
	static String sub(String api, String json) throws IOException {
		String hname = "";
	
		JsonFactory factory = new JsonFactory();
		JsonParser parser = factory.createJsonParser(json);
		while (parser.nextToken() != JsonToken.END_OBJECT) {
			String name1 = parser.getCurrentName();

			if (name1 != null) {
				parser.nextToken();
				if (name1.equals("host")) {
					hname = parser.getText();
					//System.out.println("host==" + parser.getText());
				}
			}
		}
		//System.out.println("NAME=" + hname);
		return hname;
	}
	
	   public static String start(String test) throws IOException {
		   String result;
		   if (mg != ""){
				mg = "";			
		   }
		result = (main(""));
		return result;
	   }
%>


<a target="_blank" href=<%=zbxtop%>><img
	src="<%=request.getContextPath()%>/img/zabbix_logo.png" /></a>

<!-- 
<input type="button" value="更新" onclick="refresh()" style="position: relative; left: 300px; top: -20px;"/>
 -->
<input type="button" value="更新" onclick="refresh()">
 
<div style="height: 500px; overflow-y: scroll;">
	<table border="1">

		<tr BgColor="#ffffd5">
			<th align="center">ホスト</th>
			<th align="center">時間</th>
			<th align="center">説明</th>
			<th align="center">深刻度</th>
			<th align="center">コメント</th>
			<th align="center">スクリーンへ移動</th>
		</tr>

		<%
		String mg;
		//mg = out.print(main(""));
		mg = (start(""));
		//System.out.print(mg);
		String[] array = mg.split("\n");
		for (int i = 0; i < array.length; i++) {
			int index1 = array[i].indexOf("HOST=");
			int index2 = array[i].indexOf("	TIME=");
			int index3 = array[i].indexOf("	DESCRIPTION=");
			int index4 = array[i].indexOf("	PRIORITY=");
			int index5 = array[i].indexOf("	COMMENT=");
			String host,time,description,priority,comment;
				
			host = array[i].substring(index1+5, index2);
			time = array[i].substring(index2+6, index3);
			description = array[i].substring(index3+13, index4);
			priority = array[i].substring(index4+10, index5);
			comment = array[i].substring(index5+9);

			PortletURL actionURL = renderResponse.createActionURL();
			actionURL.setParameter("name", host);
			host = "<a href='" + actionURL.toString() + "'target='_self'>" + host + "</a>";

			if (priority.matches("0")) {
				///out.print("未分類");						
			}
			else if (priority.matches("1")) {
				priority = "<FONT color=\"#00FF00\">情報</FONT>";	
			}
			else if (priority.matches("2")) {
				priority = "<FONT color=\"#FFA500\">警告</FONT>";		
			}
			else if (priority.matches("3")) {
				priority = "<FONT color=\"#FF4500\">軽度の障害</FONT>";
			}
			else if (priority.matches("4")) {
				priority = "<FONT color=\"#FF0000\">重度の障害</FONT>";
			}
			else if (priority.matches("5")) {
				priority = "<FONT color=\"#A52A2A\">致命的な障害</FONT>";	
			}

			out.print("</td><td>" + host + "&nbsp;&nbsp;&nbsp");
			out.print("</td><td>" + time + "&nbsp;&nbsp;&nbsp");
			out.print("</td><td>" + description + "&nbsp;&nbsp;&nbsp");
			out.print("</td><td>" + priority + "&nbsp;&nbsp;&nbsp");
			out.print("</td><td>" + comment + "&nbsp;&nbsp;&nbsp");
			out.print("</td><td><a target=\"_blank\" href='"+zbxsrn+"?elementid=16'target='_self'>リンク</a>");
			out.print("<tr>");

			}
		
		
		%>

	</table>
</div>
</body>
</html>


<script>
	//更新
	function refresh() {
		location.reload();
	}
</script>

<!-- 
<style type="text/css">
thead.scrollHead,tbody.scrollBody{
  display:block;
}
tbody.scrollBody{
  overflow-y:scroll;
  height:100px;
}
</style>
 -->

