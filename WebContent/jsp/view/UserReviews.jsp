<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<%@ page import="ss.beans.UserBean"%>
	<%@ page import="ss.beans.Review"%>
	<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
	<link rel="stylesheet" type="text/css" href="css/pageTab.css"></link>
	<link rel="stylesheet" type="text/css" href="css/jquery.rating.css"></link>
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<script src="js/jquery.js" type="text/javascript"></script>
	<script src="js/effects.core.js" type="text/javascript"></script>
	<script src="js/ui.core.js" type="text/javascript"></script>
	<script src="js/commonFunctions.js" type="text/javascript"></script>
	<script src="js/quickpagertable.jquery.js" type="text/javascript"></script>
	<script src="js/jquery.MetaData.js" type="text/javascript" language="javascript"></script>
	<script src="js/jquery.rating.js" type="text/javascript" language="javascript"></script>
	<script type="text/javascript">
	
	$(document).ready(function(){
		
	});
	</script>	
	<% 
		String favorite = "/img/emptyHeart.png";
		String favoriteTooltip = "Favorite this user!";
		int numReviews = 0;
		int offset = 0;
		int numPages = 0;
		UserBean viewUser = null;
		Review[] reviews = null;
		if(request.getAttribute("reviews") != null){
			reviews = (Review [])request.getAttribute("reviews");
		}
		if(request.getAttribute("isFavorite") != null){
			favorite = request.getAttribute("isFavorite").equals("favorite")? "/img/fullHeart.png":"/img/emptyHeart.png";
			favoriteTooltip = request.getAttribute("isFavorite").equals("favorite")? "Unfavorite this user!":"Favorite this user!";
		}
		if(request.getAttribute("offset") !=null){
			offset = ((Integer)request.getAttribute("offset")).intValue();
		}
		if(request.getAttribute("numReviews") !=null){
			numReviews = ((Integer)request.getAttribute("numReviews")).intValue();
		}
		if(request.getAttribute("viewUser") !=null){
			viewUser =(UserBean)request.getAttribute("viewUser");
		}
		if(numReviews % 10 == 0) numPages = numReviews/10;
		else numPages = (int)(numReviews/10) + 1;
		
	%>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>User Reviews</title>
</head>
<body>
	<jsp:include page="TopBar.jsp"></jsp:include>
	<div class="centerDiv" style="min-height:200px;">
		<%
			String ownerImg = "/img/noimage.png";
			if(viewUser.getImg() != null){
				if(!viewUser.getImg().equals("")) ownerImg = "/img/user/"+viewUser.getImg();
			}
		%>
		<img src="<%= ownerImg %>" class="userImageSml" style="float: left; padding-right: 10px; border-color: #FFF;"></img>
									<%
									int checked = (int)(viewUser.getRating() * 4);
									for(int j = 1; j<= 20; j++){
										if(j == checked){
											out.print("<input name='starTop {split:4}' type='radio' class='star {split:4}' disabled='disabled' checked='checked'/>");
										}else{
											out.print("<input name='starTop {split:4}' type='radio' class='star {split:4}'  disabled='disabled'/>") ;										
										}
									}
									%>
									<div style="margin-bottom:4px"><img src="/img/swirl.gif" style="height:20px;"></img><a href="/View?pageRequest=user&user=<%=viewUser.getId() %>" class="headerText"><%= viewUser.getName() %><%= checked %></a></div>
									<%if(session.getAttribute("user")!= null){ %><div style="width: 40px; height: 21px; text-align:left; float: right;"><input type="image" id="faveHeart"  title="<%= favoriteTooltip %>"src="<%= favorite %>" class="medHeart" onClick="toggleFave('<%= viewUser.getId() %>');"></input></div><% } %>
		<br /><br />
	<div style="width: 800px; margin-top: 40px; padding-left:45px; float:left;">
	<%
		if(reviews != null){
			if(offset == 0  && reviews.length == 0){
				%>
					<div class="review" style="text-align:center">
						No Reviews Available. :-(
					</div>
				<%
			}else{
				for(int i = 0; i<reviews.length; i++){
					Review review = reviews[i];
					if(review != null){
	
		%>
						<div id="review<%=review.getId()%>" class="review">
							<div class="reviewerName">Reviewed By:  <a href="/View?pageRequest=viewUser&viewUserId=<%= review.getReviewerId() %>"><%= review.getReviewer() %></a></div>
							<span style="width: 380px; font-size:16px;"><img src="/img/swirl.gif" style="height:16px;"></img><%= review.getName() %></span>
							<div style="float:left;"><%
							checked = (int)(review.getRating());
							for(int j = 1; j<= 5; j++){	
								if(j == checked){
									out.print("<input name='star"+ review.getId() +"' type='radio' class='star' disabled='disabled' checked='checked'/>");
								}else{
									out.print("<input name='star"+ review.getId() +"' type='radio' class='star'  disabled='disabled'/>") ;										
								}
							}%></div>
							<br /><hr style="width: 600px; border: 0px; height:1px; color: #999; background-color: #999;"/>
							<p><%= review.getContents() %></p>
						</div>		
		<%
					}
				}
			}
		}
	%>
	</div>
	<div id="pages" style="padding-left:45px; padding-top:10px; float:left;">
	<% 
		int minPage = 0;
		int maxPage = numPages;
		if(offset > 5) minPage = offset - 5;
		if((offset + 5) < numPages) maxPage = offset+5;
		if (minPage!=0){%> ... <%}
		if(maxPage!=0){
			for(int i=minPage; i<maxPage; i++){
				%>
					<a class="<%= i==offset?"current":"" %>" href="View?pageRequest=viewUserReviews&viewUserId=<%= viewUser.getId() %>&offset=<%= i %>"><%= i+1 %></a>
				<%
			}
		}
		if (maxPage!=numPages){%> ... <%}
	%>
	</div>
	</div>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
</html>