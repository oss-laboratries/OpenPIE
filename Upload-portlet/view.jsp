<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui"%>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ page import="java.io.*" %>
<%@ page import="java.lang.*" %>

<%@ page import="java.net.*" %>
<%@ page import="sun.nio.cs.*" %>
<%@ page import="java.nio.charset.Charset" %>

<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %>
<%@page import="javax.portlet.PortletURL"%>
<%@page import="javax.portlet.ResourceURL"%>
<%@page import="java.util.*"%>
<portlet:defineObjects />

<html>
<head>

<portlet:actionURL name="upload" var="uploadFileURL"></portlet:actionURL>

<aui:form action="<%= uploadFileURL %>" enctype="multipart/form-data" method="post">
<input type="file" name="fileupload" id="fileupload"/>
<div id="property"></div>
<aui:button name="アップロード" value="アップロード" type="submit" onclick="return check();"/>
</aui:form>

<script type="text/javascript">

//var input_file = "";
//var obj1 = "";
function check() {
	var obj1 = document.getElementById("fileupload");
	var obj2 = document.getElementById("property");
	var file = obj1.files[0];
	console.log("FILE="+file)
	if(file != undefined){
		//alert("OK="+obj1.files[0].name);
		if (window.confirm("ファイルをアップロードしますか？")) {
			return true;
		}
		else{
			return false;
		}
	}
	else{
		alert("ファイルを指定してください。");
		return false;
	}
}
	
	/*
	if (obj1 == undefined){
	console.log("AAAAA="+obj1.files[0].name);
    if (window.confirm("")) {
    	alert("ERR="+obj1.files[0].name);
      return true;
    } else {
    	alert("ERR="+obj1.files[0].name);
      return false;
    }
    }
	else{
		alert("NO");
		return false;
	}
  }
*/

</script>

