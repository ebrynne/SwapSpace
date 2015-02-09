<% //TODO: MERGE WITH ITEM SEARCH %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<%@ page import="ss.beans.UserBean"%>
	<%@ page import="ss.beans.ResultObject"%>
	<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
	<link rel="stylesheet" type="text/css" href="css/myItem.css"></link>
	<script src="js/jquery.js" type="text/javascript"></script>
	<script src="js/effects.core.js" type="text/javascript"></script>
	<script src="js/ui.core.js" type="text/javascript"></script>
	<jsp:useBean id="searchBean" scope="session" class="ss.beans.SearchBean"></jsp:useBean>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Search Swap Space - Users</title>
</head>
<body>
	<% if(searchBean.getLocation() == null) searchBean.autoSetLocation(request); %>
	<jsp:include page="TopBar.jsp"></jsp:include>
	<div class="centerDiv">
		<h2>Search: "<%= request.getParameter("search") %>"</h2>
		<div id="curUsers">
		<p>Here are all users that matched your search. Click on any username to follow through to the user's marketplace!</p>
		<table id="itemTable" class="pageme">
		<tbody class="mainBody">
		<%
		int pageNum = Integer.parseInt(request.getParameter("page"));
		String searchType = request.getParameter("type") == null ? "user" : request.getParameter("type");
		String query= request.getParameter("search");
		String rangeString = request.getParameter("range") == null ? "-1" : request.getParameter("range");
		int range = 0;
		try{
			range = Integer.parseInt(rangeString);
		}catch(NumberFormatException e){
			System.out.println("Error: Bad range value");
			range = -1;
		}
		int userId = -1;
		if(session.getAttribute("user")!=null) userId = ((UserBean)session.getAttribute("user")).getId();
		UserBean[] users = null;
		ResultObject[]  tempRO =  searchBean.getItems(pageNum, searchType, query, -1, "", range);
		if(tempRO != null){
			if(tempRO.length > 0){
				users = new UserBean [tempRO.length];
				for(int i = 0; i< tempRO.length; i++){
					users[i]= (UserBean)tempRO[i];
				}
				for( int i = 0; i< users.length; i++){
					UserBean curUser = users[i];
					String evenOddClass = i%2==0? "evenItem":"oddItem";
					String imgName ="/img/noimage.png";
					if(curUser.getImg() != null){
						if(!curUser.getImg().equals("")) imgName = "/img/user/"+curUser.getImg();
					}
					%>
					<tr class="<%= evenOddClass %>" id="user<%=curUser.getId()%>">
					<td>
						<table>
							<tr>
								<td colspan="2"><p class="title"><b><a class="clickableText" href="/View?pageRequest=user&user=<%= curUser.getId() %>"><%= curUser.getName() %></a></b></p><p class="errorSpace" id="error<%= curUser.getId() %>"></p></td>
							</tr>
							<tr>
								<td class="listImg" id="itemImg<%= curUser.getId() %>">
									<img src="<%= imgName %>" class="itemImageSml" id="itemImg<%= curUser.getId() %>"></img>
								</td>
								<td class="listDesc"><%= curUser.getDescription() %></td>
								<td class="listDel"  style="text-align: right;">
								<a href="/View?pageRequest=user&user=<%= curUser.getId() %>"><img src="/img/continue.png" title="Go to marketplace" onClick="removeItem(<%= curUser.getId() %>);"></img></a>
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