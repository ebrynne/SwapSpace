<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<%@ page import="ss.beans.Item"%>
	<%@ page import="ss.beans.ResultObject"%>
	<%@ page import="ss.beans.UserBean"%>
	<%@ page import="ss.utilities.LocationUtilities"%>
	<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
	<link rel="stylesheet" type="text/css" href="css/myItem.css"></link>
	<script src="js/jquery.js" type="text/javascript"></script>
	<script src="js/effects.core.js" type="text/javascript"></script>
	<script src="js/ui.core.js" type="text/javascript"></script>
	<jsp:useBean id="searchBean" scope="session" class="ss.beans.SearchBean"></jsp:useBean>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Search Swap Space - Items</title>
</head>
<body>
	<% //LocationUtilities locUtils = new LocationUtilities(searchBean.getLocation()); %>
	<jsp:include page="TopBar.jsp"></jsp:include>
	<div class="centerDiv">
		<h2>Search: "<%= request.getParameter("search") %>"</h2>
		<div id="curItems">
		<p>Here are all items that matched your search. Click on the title of any item to follow through to the marketplace at which it is offered, and start Swapping!</p>
		<table id="itemTable" class="pageme">
		<tbody class="mainBody">
		<tr>
			<% if(false){//(searchBean.getLocation()[0] != -1){ 
			%>
			<td>
				<img src="http://maps.google.com/maps/api/staticmap?center=locUtils.getLatitude(),locUtils.getLongitude()&zoom=12&size=600x250&sensor=false&maptype=roadmap&markers=color:red|label:A|locUtils.getLatitude(),locUtils.getLongitude()" alt="Your Location"></img>
			</td>
			<% } %>
		</tr>
		<%
		int pageNum = Integer.parseInt(request.getParameter("page"));
		String searchType = request.getParameter("type") == null ? "item" : request.getParameter("type");
		String query= request.getParameter("search");
		String category = request.getParameter("category");
		//String location = request.getParameter("location");
		String rangeString = request.getParameter("range") == null ? "-1" : request.getParameter("range");
		int range = 0;
		try{
			range = Integer.parseInt(rangeString);
		}catch(NumberFormatException e){
			System.out.println("Error: Bad range value");
			range = -1;
		}
		int userId = session.getAttribute("user")==null? -1: ((UserBean)session.getAttribute("user")).getId();
		Item[] items = null;
		ResultObject[] tempRO =  searchBean.getItems(pageNum, searchType, query, userId, "", range);
		if(tempRO != null){
			if(tempRO.length > 0){
				items = new Item [tempRO.length];
				for(int i = 0; i< tempRO.length; i++){
					items[i]= (Item)tempRO[i];
				}
				for( int i = 0; i< items.length; i++){
					Item curItem = items[i];
					String evenOddClass = i%2==0? "evenItem":"oddItem";
					String imgName ="/img/noimage.png";
					if(curItem.getImg() != null){
						if(!curItem.getImg().equals("")) imgName = "/img/item/"+curItem.getImg();
					}
					%>
					<tr class="<%= evenOddClass %>" id="item<%=curItem.getId()%>">
					<td>
						<table>
							<tr>
								<td colspan="2"><p class="title"><b><a class="clickableText" href="/View?pageRequest=user&user=<%= curItem.getOwnerId() %>&item=<%= curItem.getId() %>"><%= curItem.getName() %></a></b></p><p class="errorSpace" id="error<%= curItem.getId() %>"></p></td>
								<td style="width: 130px;"> <%= curItem.getCatagory() %></td>
							</tr>
							<tr>
								<td class="listImg" id="itemImg<%= curItem.getId() %>">
									<img src="<%= imgName %>" class="itemImageSml" id="itemImg<%= curItem.getId() %>"></img>
								</td>
								<td class="listDesc"><%= curItem.getDescription() %></td>
								<td class="listDel"  style="text-align: right;">
								<a href="/View?pageRequest=user&user=<%= curItem.getOwnerId() %>&item=<%= curItem.getId() %>"><img src="/img/continue.png" title="Go to marketplace" onClick="removeItem(<%= curItem.getId() %>);"></img></a>
								<br />Go to item
								</td>
							</tr>
						</table>
					</td>
					</tr>
				<%
				}
			}else{
				%>
				<tr>
				<td>
				No results found. Please refine your search.
				</td>
				</tr>
			<%
			}
		}else{
			%>
				<tr>
				<td>
				Error accessing database. Please try again later.
				</td>
				</tr>
			<%
		}
		%>
		</tbody>
		</table>
		</div>	
		<div>
		
		</div>
		<ul class="simplePagerNav">
			<%
				String searchString1 = "/Search?search=" + query + "&page=";
				String searchString2 = "&type=" + searchType + ((range > 0) ? "&range=" + range : "");
				if(searchBean.getIndexPage() != 0){
					%>
						<li>
							<a href="<%= searchString1 + "1" + searchString2 %>" rel="1">1</a>
						</li>
						<li>
							<b>...</b>
						</li>
					<%
				}
				for (int  i = searchBean.getIndexPage(); i < searchBean.getNumPages(); i++){
					if(i == pageNum){
						%>
							<li class="currentPage">
								<%= i+1 %>
							</li>
						<%
					}else{
						%>
							<li>
								<a href="<%= searchString1 + String.valueOf(i) + searchString2 %>" rel="<%= i+1 %>"><%= i+1 %></a>
							</li>	
						<%
					}
				}
			
			%>

		</ul>
	</div>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
</html>