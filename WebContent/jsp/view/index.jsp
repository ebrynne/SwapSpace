<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@ page import="ss.beans.UserBean"%>
<%@ page import="ss.beans.Item"%>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Welcome to SwapSpace</title>
<link href='http://fonts.googleapis.com/css?family=Josefin+Sans+Std+Light' rel='stylesheet' type='text/css'>
<script src="js/jquery.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
</head>
<body>
<jsp:include page="TopBar.jsp"></jsp:include>
<% if(session.getAttribute("user") == null){ %>
<div class="centerDivWide" style="height:600px;">
<!-- div style="font-family: 'Josefin Sans Std Light', arial, serif; font-weight:bold; width:1000px; float:left; height:600px; backgrsound-image:url('/img/step2.gif');"-->
<div style="width:1000px; float:left; height:600px; backgrsound-image:url('/img/step2.gif');">
	<div style="height:232px; width:1000px; background-image:url('/img/step2_01.gif')"></div>
	<div style="height:206px; width:324px; float:left; background-image:url('/img/step2_02.gif');padding-left:60px; font-size:15px; color:#FFF; "><p style="font-weight:bold; font-style:italic;">Who are we?</p> We're something new. We're a place where you <br />can trade a computer for a couch, or<br />a book for a bike. We're a place<br />where you can buy and sell<br />in a community where<br />you'll never have to<br />see another<br /> dollar bill. <br /> <br /> <span style="font-weight:bold; font-size:17px;">We are SwapSpace</span></div>
	<div style="height:206px; width:265px; float:left; background-image:url('/img/step2_03.gif;'); font-size:15px; color:#FFF; text-align:right;"><br /><br /><br /><p style="font-weight:bold; font-style:italic;">Ready to begin?</p>Just start searching here or at the top of the page for whatever tickes your fancy.<br /><br /><form action="/Search"><input type="text" id="searchText" name="search">&nbsp;&nbsp;<input type="submit" value="Search"></input><input type="hidden" name="page" value="0"></input><input type="hidden" name="type" value="item"></input></form></div>
	<div style="height:206px; width:336px; padding-left:15px; float:left; background-image:url('/img/step2_04.gif;'); font-size:15px; color:#FFF;"><p style="font-weight:bold; font-style:italic;"><br /><br /><br />Want to join us?</p>We're only as good as our users,<br />so <a href="/Controller?pageRequest=register">sign up here</a> to start building<br />your store and your community.</div>
	<div style="height:162px; width:940px; padding-right:60px; text-align:right; float:left; background-image:url('/img/step2_05.gif;'); font-size:15px; color:#FFF;"><p style="font-weight:bold; font-style:italic;">Have questions?</p>Check out our full guide<br />or our list of FAQs.</div>
	</div>
</div>
<% }else { 
	UserBean user = (UserBean)session.getAttribute("user");
	Item [] faveUserItems = (Item [])request.getAttribute("faveUserItems");
	Item [] faveSearchItems = (Item [])request.getAttribute("faveSearchItems");
	UserBean [] faveUsers = (UserBean [])request.getAttribute("faveUsers");
	String [] faveSearches = (String [])request.getAttribute("faveSearches");
	String news = (String)request.getAttribute("news");
%>
<div class="centerDiv">
	<h3>Welcome <%= user.getName() %>!</h3>
	<br />
	<% if(request.getAttribute("dirtySwaps") != null){
		int numDirtySwaps = ((Integer)request.getAttribute("dirtySwaps")).intValue(); %>
		You have <b><%= numDirtySwaps %></b> new or changed swaps. <br />
	<% } %>
	<br/><br/>
	<span style="font-size:14px;">Site Update:</span>
	<p>
	<%= news %>
	</p>
	<br/>
	<div style="width:840px; height:40px; line-height:40px; text-align:center; font-size:16px;"><span style="padding-left:94px;">New items from your favorite users</span><div style="float:right; padding-right:15px; font-size:8px;"><a type="application/rss+xml"  href="/Controller?rss=<%= user.getGuid() %>&type=user">Create RSS Feed <img src="/img/rssO.png"></img></a></div></div>
	<div class="faveList">
	<%
		if(faveUsers != null){	
			if(faveUsers.length !=0){
	%>
			<div class="pageme2" style="text-align:center">
				<% for(int i =0; i< faveUsers.length; i++){ %>
					<div class="faveListBlock">
					<div style="height:15px; width:318px;"><%= faveUsers[i].getName() %></div>
					<% for(int j=0; j< faveUserItems.length; j++){ 
						if(faveUserItems[j].getOwnerId() == faveUsers[i].getId()){
							Item curItem=faveUserItems[j];
							String imgName ="/img/noimage.png";
							if(curItem.getImg() != null){
								if(!curItem.getImg().equals("")) imgName = "/img/item/"+curItem.getImg();
							}
						%>
						<div class='swapItem swapOfferItem swapItemColors' id="swap<%= curItem.getId() %>"><b><%= curItem.getName() %></b><img class='itemImageSml' src='<%=imgName %>'></img></div>
					<% }} %>
					</div>
				<% } %>
			</div>
	<%
			
		}else{
	%>
			<div style="height:178px; padding-top:80px; text-align:center;">You have no favorite users. Time to find some!</div>
	<%
		}
		}
	%>
	</div>
	
	<br /><br /><br />
	<div style="width:840px; height:40px; line-height:40px; text-align:center; font-size:16px;"><span style="padding-left:94px;">New items from your favorite searches</span><div style="float:right; padding-right:15px; font-size:8px;"><a type="application/rss+xml"  href="/Controller?rss=<%= user.getGuid() %>&type=search">Create RSS Feed <img src="/img/rssO.png"></img></a></div></div>
	<div class="faveList">
	<%
		if(faveSearches != null){
		if(faveSearches.length !=0){
	%>
		<div class="pageme3" style="text-align:center">
			<% for(int i =0; i< faveSearches.length; i++){ %>
				<div class="faveListBlock">
				<div style="height:15px; width:318px;"><%= faveSearches[i] %></div>
				<% for(int j=0; j< faveSearchItems.length; j++){ 
					if(faveSearchItems[j].getCatagory().equals(faveSearches[i])){
						if(faveSearchItems[j].getRelevance() >0){
						Item curItem=faveSearchItems[j];
						String imgName ="/img/noimage.png";
						if(curItem.getImg() != null){
							if(!curItem.getImg().equals("")) imgName = "/img/item/"+curItem.getImg();
						}
					%>
					<div class='swapItem swapOfferItem swapItemColors' id="swap<%= curItem.getId() %>"><b><%= curItem.getName() %></b><img class='itemImageSml' src='<%=imgName %>'></img></div>
				<% }}} %>
				</div>
			<% } %>
		</div>
	<%
		}else{
	%>
			<div style="height:178px; padding-top:80px; text-align:center;">You have no favorite searches. Time to find some!</div>
	<%
		}
		}
	%>
	</div>
</div>
<% } %>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
</html>