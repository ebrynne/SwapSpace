<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<%@ page import="ss.beans.UserBean"%>
	<%@ page import="ss.beans.ConversationBean"%>
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
	<script src="js/jquery.js" type="text/javascript"></script>
	<script src="js/effects.core.js" type="text/javascript"></script>
	<script src="js/ui.core.js" type="text/javascript"></script>
	<script src="js/quickpagerdiv.jquery.js" type="text/javascript"></script>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<%
	
	if(session.getAttribute("user") == null){ response.sendRedirect("/Controller?pageRequest=home");} else{ 
		ConversationBean[] convs = {};
		if(request.getAttribute("conversations") != null){
			convs = (ConversationBean[])request.getAttribute("conversations");
		}
		
		int numConvs = 0;
		if(convs != null){
			numConvs = convs.length;
		}
	%>
	<script type="text/javascript">
		function removeMessage(id){
			if(confirm('Are you sure you want to remove this conversation? All communication with the other user will be ended.')){

			}	
		}


		$(document).ready(function() {
			$(".pageme ").quickPager( {
				pageSize: 15,
				currentPage: 1,
				pagerLocation: "after"
			});

		});
	</script>
	<style  TYPE="text/css"> 		li{
			margin-bottom:0px;
		}
	</style>
	<title>Conversations</title>
</head>
<body>
	<jsp:include page="TopBar.jsp"></jsp:include>
	<div class="centerDiv pageNumFix" style="text-align:center">
	<form method="GET" action="/Search"><input type="hidden" name="type" value="conversations"></input>Search Messages: &nbsp; &nbsp; <input class="inputBorder" type="text" name="query" id="mSearchText"></input><input type="submit" value="Search"></input></form>
		<div style="float:right; padding-right:80px;"><form method="GET" action="/User"><input type="hidden" name="conversationNew" value="true"></input><input type="Submit" name="compose" value="Compose"></input></form></div>
	
	<br /><br />
	<img src="/img/topMsg.gif"></img>
	<div class="messagesBlock pageme">
		<%
		if(numConvs != 0){
		for(int i =0; i<numConvs; i++){
			if(convs[i] != null){
		%>
			<div class="conv <%= i%2==0? "evenItem":"oddItem" %>" style="">
				<div class="convTitle" style="<%= convs[i].getDirty().equals("true")?"font-weight: bold;":"" %>cursor:pointer;" onclick="location.href='/User?pageRequest=messages&conversationId=<%=convs[i].getId() %>';"><%= convs[i].getTitle() %></div><div class="convName" style="cursor:pointer;" onclick="location.href='/User?pageRequest=messages&conversationId=<%=convs[i].getId() %>';"><%= convs[i].getOtherUser() %></div><div class="convDate" style="cursor:pointer;" onclick="location.href='/User?pageRequest=messages&conversationId=<%=convs[i].getId() %>';"><%= convs[i].getModifiedDate() %></div><div class="convDel"><img src="/img/delete.png" onclick="removeMessage(<%= convs[i].getId() %>)"style="width:20px;height:20px;"></img></div>
			</div>
		<%
			}
		}
		}else{
		%>
		<div style="width:690px; text-align:center; padding-top:8px;">No messages to display.</div>
	
		<% } %>
	</div>
	<img src="/img/btmMsg.gif"></img>
	
	</div>
	<%} %>
	<jsp:include page="BottomLinks.jsp"></jsp:include>
	
</body>
</html>