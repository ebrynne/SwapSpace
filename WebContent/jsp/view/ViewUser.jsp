<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
 <html>
<head>
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<link rel="stylesheet" type="text/css" href="css/jquery.rating.css"></link>
	<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
	<script src="/jquery.js" type="text/javascript"></script>
	<script src="/effects.core.js" type="text/javascript"></script>
	<script src="/ui.core.js" type="text/javascript"></script>	
	<script src="/commonFunctions.js" type="text/javascript"></script>
	<script src="/quickpagertable.jquery.js" type="text/javascript"></script>
	<%@ page import="ss.beans.UserBean"%>
	<% 
		String favorite = "";
		String favoriteTooltip = "";
		UserBean pageUser = (UserBean)request.getAttribute("viewUser");
		if(request.getAttribute("isFavorite") != null){
			favorite = request.getAttribute("isFavorite").equals("favorite")? "/img/fullHeart.png":"/img/emptyHeart.png";
			favoriteTooltip = request.getAttribute("isFavorite").equals("favorite")? "Unfavorite this user!":"Favorite this user!";
		}
	%>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title><%= pageUser.getName() %></title>
</head>
<body>
	<jsp:include page="TopBar.jsp"></jsp:include>
	<div class="centerDivWide">
		<%
			String ownerImg = "/img/noimage.png";
			String location = "No location information available";
			if(pageUser.getLocation()!= null){
				if(!pageUser.getLocation().equals("")) location = pageUser.getLocation();
			}
			if(pageUser.getImg() != null){
				if(!pageUser.getImg().equals("")) ownerImg = "/img/user/"+pageUser.getImg();
			}
		%>
		<img src="<%= ownerImg %>" class="userImageSml" style="float: left; padding-right: 10px; border-color: #FFF;"></img><span class="headerText"><%= pageUser.getName() %></span><%if(session.getAttribute("user")!= null){ %><div style="width: 40px; height: 21px; text-align:left; float: right;"><input type="image" id="faveHeart"  title="<%= favoriteTooltip %>"src="<%= favorite %>" class="medHeart" onClick="toggleFave('<%= pageUser.getId() %>');"></input></div><% } %>
		<br /><br />
		<b>Location:&nbsp;&nbsp;&nbsp;</b><%= location %>
		<br /><br />
		<b>Description:&nbsp;&nbsp;&nbsp;</b><%= pageUser.getDescription() %>
		<br /><br />
		<b>Interested In:&nbsp;&nbsp;&nbsp;</b><%= pageUser.getLookingFor() %>
		<br /><br />
		Read the <a href="/View?pageRequest=viewUserReviews&viewUserId=<%= pageUser.getId() %>">reviews</a> for this user.
	</div>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
</html>