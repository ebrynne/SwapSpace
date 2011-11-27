<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
   <%@ page import="ss.beans.UserBean" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<jsp:useBean id="resources" scope="application" class="ss.beans.ResourceBean" /> 
<jsp:useBean id="searchBean" scope="session" class="ss.beans.SearchBean"></jsp:useBean>
<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
<script src="/jquery.js" type="text/javascript"></script>
<script src="/effects.core.js" type="text/javascript"></script>	
<title>Advanced Search</title>
<script type="text/javascript">
	function showHideCategory(){
		if($("#itemRadio").is(':checked')){
			$("#categoryDiv").slideDown("fast");
		}else{
			$("#categoryDiv").slideUp("fast");
		}
	}
</script>
</head>
<body>
<jsp:include page="TopBar.jsp"></jsp:include>
<div class="centerDiv">
<h2>Advanced Search</h2>
<br />
<form action="/Search">
Search Type: <input type="radio" name="type" value="item" checked="checked" id="itemRadio" onClick="showHideCategory();"/> Item (Search item postings) &nbsp; &nbsp; &nbsp; &nbsp;<input type="radio" name="type" value="user" onClick="showHideCategory();"/> User (Search users' interests, name, and what they're looking for)
<br />
<% if(searchBean.getLocation() == null) searchBean.autoSetLocation(request); %>
<% boolean hasLocation=false; if(searchBean.getLocation()[0] != -1 ){ hasLocation=true; } %>
<br /><span style="color:<%= hasLocation? "#000":"#AAA"%>;">Location Range (Kilometers):</span> <input <%= hasLocation? "":"readOnly=\"readOnly\"" %>" onBlur="for(var i=0; i< this.value.length; i++){ charCode= this.value.charAt(i); if(((charCode < '0') || (charCode > '9'))){ this.value=''; alert('Please enter a numeric value for distance.');}}" name="locationRange" ></input> <%= hasLocation? "":"This service can only be used by registered users with a set location." %>
<br /><br />Search Text: <input type="text" name="search" ></input>
<div id="categoryDiv"><br />Category: <select class="inputBorder" name="newItemCategory" id="newItemCategory">
				<option>All</option>
				<%
				for(int i = 0; i < resources.getCategories().length; i++){
				%>
					<option><%=resources.getCategories()[i] %></option>
				<%
				}
				
				%></select></div>
<br /><br /><input type="submit" value="Search"></input>
<input type="hidden" name="page" value="0"></input>
</form>
</div>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
</html>