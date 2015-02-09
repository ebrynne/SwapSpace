<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<%@ page import="ss.beans.UserBean"%>
	<%@ page import="ss.beans.MessageBean"%>
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
	<link rel="stylesheet" type="text/css" href="css/dropdown.css"></link>
	<script src="js/jquery.js" type="text/javascript"></script>
	<script src="js/acdropdown.js" type="text/javascript"></script>
	<script src="js/modomt.js" type="text/javascript"></script>
	<script src="js/getobject2.js" type="text/javascript"></script>
	<script src="js/effects.core.js" type="text/javascript"></script>
	<script src="js/ui.core.js" type="text/javascript"></script>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<%
	if(session.getAttribute("user") == null){ response.sendRedirect("/Controller?pageRequest=home");} else{ 
		UserBean user = (UserBean)session.getAttribute("user");
		MessageBean[] messages = {};
		if(request.getAttribute("messages") != null){
			messages= (MessageBean[])request.getAttribute("messages");
		}
		
		UserBean [] friends = null;
		if(request.getAttribute("friends")!=null){
			friends = (UserBean [])request.getAttribute("friends");
		}
		
		int numMes = 0;
		if(messages != null){
			numMes = messages.length;
		}
		
		boolean newSwap = false;
		if(request.getAttribute("newSwap")!= null){
			newSwap = (request.getAttribute("newSwap").toString()).equals("true");
		}
		
		int swapId =0;
		if(request.getAttribute("swapId")!= null){
			swapId = ((Integer)request.getAttribute("swapId")).intValue();
		}
		
		int otherUser = -1;
		for(int i=0; i< messages.length; i++){
			if(messages[i].getOwnerId()!=user.getId()){
				otherUser = messages[i].getOwnerId();
				break;
			}
		}
		if(request.getAttribute("otherUser") != null){
			otherUser = ((Integer)request.getAttribute("otherUser")).intValue();
		}
		
		boolean newConv = false;
		if(request.getAttribute("newConv") != null){
			newConv = true;
		}
		
		
	%>
	<script type="text/javascript">
		function userObject(name, id){
			this.name = name;
			this.id= id;
		}
	
		function toggleView(msgId){
			$("#hideMsg"+msgId).slideToggle("normal");
			if($("#viewText"+msgId).html() == "View"){
				$("#viewText"+msgId).html("Hide");
			}else{
				$("#viewText"+msgId).html("View");
			}
		}

		function toggleAll(open, numMes){
			for(i=0;i<numMes;i++){
				if(open == 1){
					$("#hideMsg"+i).slideDown("normal");
					$("#viewText"+i).html("Hide");
				}else{
					$("#hideMsg"+i).slideUp("normal");
					$("#viewText"+i).html("View");
				}
			}
		}

		var friendsInfoArray = new Array(<% if(friends!=null){ for(int i=0; i<friends.length;i++){%>new userObject('<%=friends[i].getName()%>',<%=friends[i].getId()%>)<%=i<(friends.length-1)?",":"" %><% }} %>);
		var friendsArray = new Array(<% if(friends!=null){ for(int i=0; i<friends.length;i++){%>'<%=friends[i].getName()%>'<%=i<(friends.length-1)?",":"" %><% }} %>);
		
		function clearWho(){
			var content = $("#friendDrop").val();
			var i = 0;
			var inArray = false;
			while (i < friendsInfoArray.length) {
				if (friendsInfoArray[i].name == content) {
					inArray = true;
					$("#otherUserId").val(friendsInfoArray[i].id);
				}
				i++;
			}
			if( inArray == false){ 
				$("#friendDrop").val("");
				$("#otherUserId").val(-1);
			}
		}

		function readySubmit(){
			var readySubmit = true;
			if($("#newSwap").val()=="true" || $("#newConv").val()=="true"){
				if($("#title").val().length < 3) readySubmit = false;
			}
			if( $("#newConv").val()=="true"){
				var inArray = false;
				var content = $("#friendDrop").val();
				
				var i=0;
				while (i < friendsInfoArray.length) {
					if (friendsInfoArray[i].name == content) {
						inArray = true;
					}
					i++;
				}
				if(!inArray) readySubmit=false;
			}
			if($("#content").val().length<3){
				readySubmit=false;
			}

			if(readySubmit==true){
				$("#sendMessage").attr("disabled", false);
			}else{
				$("#sendMessage").attr("disabled", true);
			}
			
		}
		function formatFriends( sText ){
		    return sText.substr( 0, this.sActiveValue.length ).bold().fontcolor( '#08208' ) + sText.substr( this.sActiveValue.length );
		}

		function toggleReply(){
			$("#replyText").slideToggle("normal");
		}
	</script>
<title>My Messages</title>
</head>
<body>
	<jsp:include page="TopBar.jsp"></jsp:include>
	<div class="centerDiv" style="text-align:center">
		<div style="text-align:right;">
			<input type="button" value="Expand All" onclick="toggleAll(1, <%=numMes %>)"></input>&nbsp;<input type="button" value="Hide All" onclick="toggleAll(0, <%=numMes %>)"></input><% if(!newSwap){ %><input type="button" value="Reply" onClick="toggleReply()"></input><% } %>
		</div>
		<br />
		<div style="<%= newSwap||newConv?"": "display:none;"%> text-align:lefst;" id="replyText">
		<form method="POST" action="/User">
		<% if(newSwap||newConv){ %><span style="font-size:16px;">Title:</span>&nbsp;<input type="text" name="title" id="title" class="inputBorder" onKeyUp="readySubmit()"></input><br /><br /> <%} %>
		<% if(newConv){%><span style="font-size:16px;"><input type="hidden" value="true" name="newConv" id="newConv"></input><input type="hidden" value="-1" name="otherUser" id="otherUserId"></input>To:</span><input class="dropdown" autocomplete="off" style="width: 250px;" acdropdown="true" autocomplete_list="array:friendsArray" autocomplete_format="formatFriends" autocomplete_complete="true" id="friendDrop" onblur="clearWho(); readySubmit();"> </input><% } %>
		<h2><%=newSwap||newConv?"Compose Mail:":"Reply" %></h2>
		<textarea name="content" id="content" onKeyUp="readySubmit()" style="height:300px; width:600px; font-family: Helvetica, Verdana, Georgia, sans-serif;" class="inputBorder"></textarea>
		<br />
		<input type="submit" id="sendMessage" value="Send" disabled="disabled"></input>
		<% if(newSwap){ %><input type="hidden" value="true" id="newSwap" name="newSwap"></input><% }else if(newConv){ %><input type="hidden" value="newConv" name="newSwap"></input><% } %> 
		<% if(numMes > 0){ %><input type="hidden" value="<%= messages[0].getConversationId() %>" name="conversationId"></input> <% } %>
		<% if(otherUser != -1){ %><input type="hidden" value="<%=otherUser %>" name="otherUser"></input><%} %>
		<% if(swapId != -1){ %><input type="hidden" value="<%= swapId %>" name="swapId"></input><% } %>
		<input type="hidden" name="notajax" value="message"></input>
		</form>
		</div>
		<%
		if(numMes > 0){
			for(int i = 0; i<numMes; i++){
				%>
					<div onClick="toggleView(<%= i %>)">
					<img src="/img/curvebartop.png" style="padding:0px; margin:0px;"></img>
					<div class="curveBoxFormat" id="mess<%= i %>" style="margin: 0 auto; text-align:left; font-size: 14px;">
						<div style="width:300px; float:left;"><%= messages[i].getOtherUser() %></div><div style="float:left;"><%= messages[i].getCreateDate() %></div><div style="float:right" class="link" id="viewText<%= i %>">View</div>
							<br />
							<div style="display:none; font-size:12px;" id="hideMsg<%= i %>">
								<div style="text-align:center"><hr style="color:#FFF;width=600px;"/></div>
								<br />
								<%= messages[i].getContent() %>
							</div>
						</div>
						<img src="/img/curvebarbottom.png" style="padding:0px; margin:0px;"></img>
					</div>
					<br />
				<%
			}
			
		}else if(numMes <=0 && !newSwap && !newConv){
			%>
				<br />
				<br />
				Sorry, there are no messages. You should probably never see this.
			<%
		}
		
		%>
		
	<br />
	</div>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
<% } %>
</html>