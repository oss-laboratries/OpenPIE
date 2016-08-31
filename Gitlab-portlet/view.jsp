<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="theme" %>
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
<%@ page import="com.liferay.portal.kernel.util.ParamUtil"%>

<portlet:defineObjects />
<%!

public static String dir = "/opt/liferay/config/";
public static String git_cfg = "portlet_config";
//public static String  giturl,gitpjtid,gittoken,portname,lifepath,gitusr,gitpjname;
//public static String  giturl,gittoken,portname,lifepath,gitusr;
public static String  gitpjname,gitpjtid = "";
public static String [] val = new String[10];
public static String mg = "";
public static String marjsp = "";
public static String lifepath="",cnf;
public static String giturl = "";
//public static String gitpjtid = "";
//public static String portname = "";
public static String gittoken = "";
public static String gitusr = "";
public static String flserver = "";
public static String portname = "GitLab-portlet";
%>

<%

// GitLab情報の取得
BufferedReader in = new BufferedReader(new FileReader(dir + git_cfg));
int j=0;
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

}	
in.close();

gitpjname = ParamUtil.getString(request, "pname");
gitpjtid = ParamUtil.getString(request, "pid");

//System.out.println("gitpjname="+gitpjname);
//System.out.println("gitpjtid="+gitpjtid);
%>

<%!

public static String marge(String mar) throws IOException {

	//不要な括弧を削除
		 String strBefore1="\\[\\{";
		 String strAfter1="{";
		 String strBefore2="},$";
		 String strAfter2="}]";
		 mar = mar.replaceAll(strBefore1, strAfter1);
		 mar = mar.replaceAll(strBefore2, strAfter2);
		 mar = "["+mar;
//		 marjsp = mar;

		 mar = mar.replaceAll("},", "},\n");
		//javascript用の変数を設定
		 marjsp = mar;
		//取得、整形したjsonをファイルに書き込み

		 FileWriter fw_tmp = new FileWriter(lifepath +"/webapps/" + portname +"/tree.json");
		 PrintWriter pw_tmp = new PrintWriter(new BufferedWriter(fw_tmp));
		 pw_tmp.println(mar);
		 pw_tmp.close();
		 return "";
	 }
	 
	 public static String api(String path, String parent, int level) throws IOException {

		 /*
		String giturl = "http://192.168.100.242",
				gitpjt = "1",
				gittoken = "_AS2JYyccyoqDcXWT2Mg";
		String tree = ".*(tree)+.*";
//		String mg = "";
*/
		String tree = ".*(tree)+.*";
		//GitLabファイル情報取得API実行
		URL apiUrl=new URL(giturl +"/api/v3/projects/"+ gitpjtid +"/repository/tree?path="+path+"&reg=master&private_token="+ gittoken);
		HttpURLConnection huc =  (HttpURLConnection)  apiUrl.openConnection(); 
		huc.setRequestMethod("GET"); 
		huc.connect(); 
		//System.out.println("="+huc.getResponseCode());
		if (huc.getResponseCode() == 200){
		String line,json="";
		BufferedReader reader = new BufferedReader(new InputStreamReader(apiUrl.openStream(), "UTF-8"));
		//System.out.println("TEST="+reader);
		while((line = reader.readLine()) != null){
		    json+=line;
		}
		reader.close();

//		System.out.println("API="+json);
		//取得したjsonを一行づつ配列に格納
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
///				System.out.println("path="+path);
				String strBefore2="},|}]";
				String strAfter2=",\"fullpath\":\"\",\"level\":"+level+",\"parent\":\""+parent+"\",\"size\":\"\",\"revision\":\"\",\"isLeaf\":\"false\",\"expanded\":\"false\",\"loaded\":\"true\"},";
				array[i]=array[i].replaceAll(strBefore2, strAfter2);
				mg = mg+array[i];
//				return dir;
//				System.out.println("LEVEL="+level);
				parent = array[i].substring(index+6, index2);
//				System.out.println("PARENT="+parent);
//				System.out.println(array[i]);
				//再帰呼び出し
				api(dir,parent,level+1);
			}
			else{
				String filename =array[i].substring(index2+10, index3);
				String strBefore2="},|}]";
				//String strAfter2=",\"level\":"+level+",\"parent\":\""+parent+"\",\"isLeaf\":\"true\",\"expanded\":\"true\",\"loaded\":\"true\"},";

				URL apiUrl2=new URL(giturl +"/api/v3/projects/"+ gitpjtid +"/repository/files?file_path="+path+"/"+filename+"&ref=master&private_token="+ gittoken);
				String line2,json2="";
				BufferedReader reader2 = new BufferedReader(new InputStreamReader(apiUrl2.openStream(), "UTF-8"));
				while((line2 = reader2.readLine()) != null){
				    json2+=line2;
				}
				reader2.close();
//				System.out.println(json2);

				//サイズ抜きし
				int index4 = json2.indexOf("\",\"size\"");
				int index5 = json2.indexOf(",\"encoding\":");
				String size = json2.substring(index4+9, index5);
//				System.out.println(size);

				//リビジョン抜き出し
				int index6 = json2.indexOf("\",\"last_commit_id\"");
				int index7 = json2.indexOf("\"}");
				String revision = json2.substring(index6+20, index7);
				//System.out.println("commitid="+revision);

				
				if(level == 0){
					String strAfter2=",\"fullpath\":\""+filename+"\",\"level\":"+level+",\"parent\":\"\",\"size\":\""+size+"\",\"revision\":\""+revision+"\",\"isLeaf\":\"true\",\"expanded\":\"true\",\"loaded\":\"true\"},";
					array[i]=array[i].replaceAll(strBefore2, strAfter2);
//					System.out.println(array[i]);
				}
				else{
					String strAfter2=",\"fullpath\":\""+path+"/"+filename+"\",\"level\":"+level+",\"parent\":\""+parent+"\",\"size\":\""+size+"\",\"revision\":\""+revision+"\",\"isLeaf\":\"true\",\"expanded\":\"true\",\"loaded\":\"true\"},";
					array[i]=array[i].replaceAll(strBefore2, strAfter2);
//					System.out.println(array[i]);
				}
				
				mg = mg+array[i];
			}
//			return path;
			
		}
///		System.out.println("MG=="+mg);
		marge(mg);
		}
		return "";
		
	   }

	   
	   public static String start(String test) throws IOException {
		   //宣言部の変数mg,marjsp初期化
		   if (mg != ""){
				mg = "";
				marjsp ="";
				
		   }
		   if (gitpjname != ""){
					api("","",0);

		   }
		   else {
			   marjsp = "[]";
		   }
		return "";
	   }
%>


<%=start("") %> 

<html> 


<body> 
<h3>プロジェクト：<%= gitpjname %></h3>
<input type="button" value="リポジトリダウンロード" onclick="download()" />
<table id="list"></table> 

</body>
</html> 

<style type="text/css">
	html, body {
	margin: 0;
	padding: 0;
	}
</style>
    
<script type="text/javascript">

	var giturl = "<%= giturl %>";
	var gitpjname = "<%= gitpjname %>";
	var gitpjtid = "<%= gitpjtid %>";
	var gittoken = "<%= gittoken %>";
	var gitusr = "<%= gitusr %>";
	var mydata = <%= marjsp %>;
//	var mydata = [{"id":"7ec9a4b774e2472d8e38bc18a3aa1912bacf483e","name":"aa.sh","type":"blob","mode":"100644","fullpath":"aa.sh","level":0,"parent":"","isLeaf":"true","expanded":"true","loaded":"true"},{"id":"881841f148a5aaa7713645a659bc780bbffdce5c","name":"bb.sh","type":"blob","mode":"100644","fullpath":"bb.sh","level":0,"parent":"","isLeaf":"true","expanded":"true","loaded":"true"}]

/*
	console.log(giturl);
	console.log(gitpjname);
	console.log(gitpjtid);
	console.log(gittoken);
	console.log(gitusr);
	console.log(mydata);
*/
    console.log(mydata);
	if (mydata != ""){
	
	$("#list").jqGrid({
		datatype: "jsonstring",
		datastr: mydata,
		colNames:['名称','サイズ(byte)','リビジョン','表示'],
		colModel :[ 
			{name:'name', index:'name'}, 
			{name:'size', index:'size', align: 'right', formatter:separate},
			{name:'revision', index:'revision'},
			{name:'fullpath', index:'fullpath' ,formatter: linkFormatter},
		],			
		gridview: true,
     	treeGrid: true,
       treeGridModel: 'adjacency',
       treedatatype: "local",
      	ExpandColumn : 'name', 
       caption: 'GitLabポートレット',
		treeIcons: {leaf:'ui-icon-document'},
		jsonReader: {repeatitems: false},
		pager: '#pager',
		viewrecords: true,
		gridview: true,
		height: 'auto',
		width: 'auto'
	});
	
	}
	else{
		document.write("<BR>プロジェクトを選択後、リポジトリが表示されます。<BR>");
	}
	
	//リビジョンカンマ区切り
	function separate(num){
		return String(num).replace( /(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
	}
	
	//ダウンロードリンク先生成
	function showLink(fullpath) {
		window.open(giturl +"/" +gitusr + "/"+gitpjname+"/raw/master/"+fullpath+"?private_token="+gittoken);
	}

	//ファイル内容表示
	function linkFormatter(cellvalue, options, rowdata) {
		if (cellvalue != ""){
			var val = "<a href=\"javascript:void(0);\" onclick=\"showLink('" + cellvalue + "');\">ファイル内容表示</a>";
			return val;
		}
		else{
			return "";
		}
	}

	//ダウンロード
	function download(){
		if (mydata != ""){
			ret = confirm("リポジトリファイルをダウンロードしますか？");
			if (ret == true){
				location.href = giturl +"/"+ gitusr + "/" + gitpjname +"/repository/archive.zip?ref=master&private_token="+gittoken;
			}
		}
		else{
			alert("プロジェクトを選択してください");
		}
	}

</script>
</head>
<body>
	<div style="margin: 10px;">
		<table id="list"></table> 
		<div id="pager"></div> 
	</div>
</body>

	