<head>
<%@page import="ss.beans.UserBean"%>
</head>
<body>
<% if(session.getAttribute("user")!= null){
	int numDirtySwaps = 0;
	if(request.getAttribute("dirtySwaps") != null){
		numDirtySwaps = ((Integer)request.getAttribute("dirtySwaps")).intValue();
	}
	int numDirtyConv = 0;
	if(request.getAttribute("dirtyMess")!= null){
		numDirtyConv = ((Integer)request.getAttribute("dirtyMess")).intValue();
	}
%>
	<a href="/User?pageRequest=home">Home</a><br />
	<a href="/User?pageRequest=myItems">My Items</a><br />
	<% if(numDirtySwaps > 0){ %><b><% } %>
	<a href="/User?pageRequest=mySwaps" id="swapLink">My Swaps<% if(numDirtySwaps > 0){ %>(<%= numDirtySwaps %>)</b><% } %></a><br />
	<% if(numDirtyConv > 0){ %><b><% } %>
	<a href="/User?pageRequest=conversations">Messages<% if(numDirtyConv > 0){ %>(<%= numDirtyConv %>)</b><% } %></a><br />
	<a href="/User?pageRequest=accountSettings">Account Settings</a><br />
	<a href="/Controller?pageRequest=logout">Logout</a>
	
<% }else{ %>
	<a id="loginPopup" href="jsp/view/Login.jsp" title="Login to SwapSpace!">Login</a> or <a href="/Controller?pageRequest=register">Register</a>
<% } %>
</body>
