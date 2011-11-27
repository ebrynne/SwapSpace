<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<%@ page import="ss.beans.Item"%>
	<%@ page import="ss.beans.ResultObject"%>
	<%@ page import="ss.beans.UserBean"%>
	<%@ page import="ss.beans.Note"%>
	<% 
		Item[] myItems = {};
		Note[] notes = {};
		Item[] userItems = {};
		String widthFix = session.getAttribute("user")!= null ? "fixMyItemTheirItemBreak":"";
		String centerClass = session.getAttribute("user")!= null ? "centerDivWide":"centerDivViewStore";
		String favorite = "";
		String favoriteTooltip = "";
		if(request.getAttribute("isFavorite") != null){
			favorite = request.getAttribute("isFavorite").equals("favorite")? "/img/fullHeart.png":"/img/emptyHeart.png";
			favoriteTooltip = request.getAttribute("isFavorite").equals("favorite")? "Unfavorite this user!":"Favorite this user!";
		}
		if(request.getAttribute("userItems") != null){
			userItems = (Item[])request.getAttribute("userItems");
		}
		if(request.getAttribute("myItems") != null){
			myItems = (Item[])request.getAttribute("myItems");
		}
		if(request.getAttribute("notes") != null){
			notes = (Note[])request.getAttribute("notes");
		}
		
		int numUserItems = 0;
		int numMyItems = 0;
		if(userItems != null){
			numUserItems = userItems.length;
		}
		if(myItems!=null){
			numMyItems = myItems.length;
		}

	%>
	<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
	<link rel="stylesheet" type="text/css" href="css/ui.tabs.css"></link>
	<link rel="stylesheet" type="text/css" href="css/myItem.css"></link>
	<link rel="stylesheet" type="text/css" href="css/pageTab.css"></link>
	<script src="/jquery.js" type="text/javascript"></script>
	<script src="/effects.core.js" type="text/javascript"></script>
	<script src="/ui.core.js" type="text/javascript"></script>
	<script src="/ui.tabs.js" type="text/javascript"></script>
	<script src="/commonFunctions.js" type="text/javascript"></script>
	<script src="/quickpagerdiv.jquery.js" type="text/javascript"></script>
	<script src="/jquery.MetaData.js" type="text/javascript" language="javascript"></script>
	<style type="text/css">
		div.ui-tabs.ui-widget.ui-widget-content.ui-corner-all{
			padding-bottom:80px;
		}
		div.ui-tabs-panel.ui-widget-content.ui-corner-bottom{
			padding-left:0px;
			padding-right:0px;
		}
	</style>
	
	<title>View Store</title>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<script type="text/javascript">
	
	
	function swapToggle(itemId, itemName, imgName, isMyItem){
		var imgPath = "/img/noimage.png";
		if($("#swap"+itemId).size() > 0){
			$("#swap"+itemId).fadeOut("normal");
			$("#swap"+itemId).remove();
			$("#toggle"+itemId).attr("src", "/img/add.png");
			if(!$("#myItems tbody tr td").size() > 0 || !$("#theirItems tbody tr td").size() > 0){
				$("#makeOffer").attr("disabled", "disabled");	
			}
		}else{
			if(imgName != null){
				if(imgName != ""){
					imgPath = "/img/item/" +imgName;
				}
			}
			if(isMyItem){
				var numRows = $("#myItems tbody tr").size();
				var listItems = $("#myItems tbody tr");
				$("#myItems tbody tr").each(function(index){
					var child = $(this);
					if(child.children("td").size() < 3){
						child.html(child.html() + "<td class='swapItem swapItemColors' id='swap"+itemId+"' style='display:none;'><b>"+ itemName +"</b><input type='hidden' name='itemId"+itemId+"' value='"+itemId+"'></input><input id='toggle"+itemId+"' type='image' src='/img/remove.png' onClick=\"swapToggle('"+itemId+"', '"+itemName+"', '"+imgName+"',  true);\" style='width:20px; height:20px;'></input><img class='itemImageSml' src='"+ imgPath +"'></img></td>");
					}else{
						if(index+1 == numRows){
							$("#myItems tbody").html($("#myItems tbody").html() + "<tr><td class='swapItem swapItemColors' id='swap"+itemId+"' style='display:none;'><b>"+ itemName +"</b><input type='hidden' name='itemId"+itemId+"' value='"+itemId+"'></input><input id='toggle"+itemId+"' type='image' src='/img/remove.png' onClick=\"swapToggle('"+itemId+"', '"+itemName+"', '"+imgName+"',  true);\" style='width:20px; height:20px;'></input><img class='itemImageSml' src='"+ imgPath +"'></img></td></tr>");
						}
					}
					$("#swap"+itemId).fadeIn("normal");
				});
				if($("#theirItems tbody tr td").size() > 0){
					$("#makeOffer").attr("disabled", false);	
				}
				
			}else{
				var numRows = $("#theirItems tbody tr").size();
				var listItems = $("#theirItems tbody tr");
				$("#theirItems tbody tr").each(function(index){
					var child = $(this);
					if(child.children("td").size() < 3){
						child.html(child.html() + "<td class='swapItem swapItemColors' id='swap"+itemId+"' style='display:none;'><b>"+ itemName +"</b><input type='hidden' name='itemId"+itemId+"' value='"+itemId+"'></input><input id='toggle"+itemId+"' type='image' src='/img/remove.png' onClick=\"swapToggle('"+itemId+"', '"+itemName+"', '"+imgName+"',  false);\" style='width:20px; height:20px;'></input><img class='itemImageSml' src='"+ imgPath +"'></img></td>");
					}else{
						if(index+1 == numRows){
							$("#theirItems tbody").html($("#theirItems tbody").html() + "<tr><td class='swapItem swapItemColors' id='swap"+itemId+"' style='display:none;'><b>"+ itemName +"</b><input type='hidden' name='itemId"+itemId+"' value='"+itemId+"'></input><input id='toggle"+itemId+"' type='image' src='/img/remove.png' onClick=\"swapToggle('"+itemId+"', '"+itemName+"', '"+imgName+"',  false);\" style='width:20px; height:20px;'></input><img class='itemImageSml' src='"+ imgPath +"'></img></td></tr>");
						}
					}
					$("#swap"+itemId).fadeIn("normal");
				});
				if($("#myItems tbody tr td").size() > 0){
					$("#makeOffer").attr("disabled", false);	
				}
			}
			$("#toggle"+itemId).attr("src", "/img/remove.png");
		}
	}
	
	$(document).ready(function() {
		$(".pageme ").quickPager( {
			pageSize: 6,
			currentPage: 1,
			pagerLocation: "after"
		});

		$(".pageSide ").quickPager( {
			pageSize: 5,
			currentPage: 1,
			pagerLocation: "after"
		});

		$("#notesTable ").quickPager( {
			pageSize: 10,
			currentPage: 1,
			pagerLocation: "after"
		});
		
	    $("#tabs").tabs();

	    $(".simplePagerNav").onClick(function(){
			$("#main").height(2000);
		});
		
	});
	</script>
</head>
<body>
	<jsp:include page="TopBar.jsp"></jsp:include>
	<div class="<%= centerClass %>" id="main">

		<%
			UserBean storeOwner = (UserBean)request.getAttribute("storeOwner");
			String ownerImg = "/img/noimage.png";
			String location = "No location information available";
			if(storeOwner.getLocation()!= null){
				if(!storeOwner.getLocation().equals("")) location = storeOwner.getLocation();
			}
			if(storeOwner.getImg() != null){
				if(!storeOwner.getImg().equals("")) ownerImg = "/img/user/"+storeOwner.getImg();
			}
		%>
		<img src="<%= ownerImg %>" class="userImageSml" style="float: left; padding-right: 10px; border-color: #FFF;"></img><div class="headerText"><%= storeOwner.getName() %></div><%if(session.getAttribute("user")!= null){ %><div style="width: 40px; height: 21px; text-align:left; float: right;"><input type="image" id="faveHeart"  title="<%= favoriteTooltip %>"src="<%= favorite %>" class="medHeart" onClick="toggleFave('<%= storeOwner.getId() %>');"></input></div><% } %>
		<br />
		Read the <a href="/View?pageRequest=viewUserReviews&viewUserId=<%= storeOwner.getId() %>">reviews</a> for this user.
		<br /><br />
		<b>Location:&nbsp;&nbsp;&nbsp;</b><%= location %>
		<br /><br />
		<b>Description:&nbsp;&nbsp;&nbsp;</b><%= storeOwner.getDescription() %>
		<br /><br />
		<b>Interested In:&nbsp;&nbsp;&nbsp;</b><%= storeOwner.getLookingFor() %>
		<br /><br />
		<div id="tabs">
		<ul>
			<li><a href="#swapData">Swap Items</a></li>
			<li><a href="#notesData">Bulletin Board</a></li>
		</ul>
		<div id="swapData">
		<%if(session.getAttribute("user")!= null){ %>
		<div id="carryPageNums" style="float:right;">
		<% if(myItems != null){ %>
			<div style="width:150px;border: #777 thin solid; ">
			<div style="text-align:center; width:148px; height:30px;"><h2>My Items</h2></div>
			<div class="pageSide" >
				<% if(numMyItems > 0){
					for(int i = 0; i< numMyItems; i++){ 
					Item curItem = myItems[i];
					String evenOddClass = i%2==0? "evenItem":"oddItem";
					String imgName ="/img/noimage.png";
					if(curItem.getImg() != null){
						if(!curItem.getImg().equals("")) imgName = "/img/item/"+curItem.getImg();
					}
					%>
					<div class="<%= evenOddClass %> mySwapItem" id="item<%= curItem.getId() %>" style="vertical-align: middle;"><b><%= curItem.getName() %></b><input id="toggle<%= curItem.getId() %>"type="image" src="/img/add.png" onClick="swapToggle('<%= curItem.getId() %>', '<%= curItem.getName() %>', '<%= curItem.getImg() %>',  true);" style="width:20px; height:20px;"></input><img class='itemImageSml' src="<%= imgName %>"></img></div>
				<% 
					}
				}else{ %>
				<div class="swapItem">No Items</div>
				<% } %>
			</div>
			</div>
		</div>
		<% } %>
	<% } %>
	
		<div style="padding:6px;">Either click the plus sign, or drag an item to the Exchange box to add their and your items to the swap. Then hit the "Make Offer" button!</div><br />
		<div id="fixBulge pageNumFix" style="width:830px;">
		<div id="itemTable" class="pageme" style="width:830px;">
		<%
		if(numUserItems != 0){
			for(int i = 0; i < numUserItems; i++){
				Item curItem = userItems[i];
				String evenOddClass = i%2==0? "evenItem":"oddItem";
				String imgName ="/img/noimage.png";
				if(curItem.getImg() != null){
					if(!curItem.getImg().equals("")) imgName = "/img/item/"+curItem.getImg();
				}
				%>
	
				<div class="<%= evenOddClass %>" id="item<%=curItem.getId()%>">
					<table>
					<tr>
					<td colspan="2"><p class="title"><b><%= curItem.getName() %></b></p><p class="errorSpace" id="error<%= curItem.getId() %>"></p></td>
					<td> <%= curItem.getCatagory() %></td>
					</tr>
					<tr>
					<td class="listImg" id="itemImg<%= curItem.getId() %>">
						<img src="<%= imgName %>" class="itemImageSml" id="itemImg<%= curItem.getId() %>"></img>
					</td>
					<td class="listDesc"><%= curItem.getDescription() %></td>
					<td class="listDel" style="text-align: right;">
					<%if(session.getAttribute("user")!= null){ %>
					<input id="toggle<%= curItem.getId() %>" type="image" src="/img/add.png" onClick="swapToggle('<%= curItem.getId() %>', '<%= curItem.getName() %>', '<%= curItem.getImg() %>',  false);"></input>
					<% } %>
					</td>
					</tr>
					</table>
				</div>
				<%	
			}
		}else{
			%>
			<div>
			<p id="noItemMsg" class="center">No Items Uploaded</p>
			</div>
			<%	
		}
		%>
		</div>
		</div>
	</div>
	<div id="notesData" style="">
		<div id="notes" style="width:800px; border: solid thin #999;<%= session.getAttribute("user")!= null?"margin-left:90px;":"" %>">
		<div id="notesTable" >
		<%for(int i = 0; i<notes.length; i++){ %>
		<div class="note <%= i%2==0?"evenItem":"oddItem" %>">
		<a href="/View?pageRequest=user&user=<%= notes[i].getUserId() %>"><%= notes[i].getUserName() %></a> said:&nbsp; &nbsp; <%= notes[i].getContent() %>
		</div>
		<% }%></div>
		<% if(session.getAttribute("user")!= null){ %>
			<br />
			<br />
			<form action="/View" method="GET">
			<input type="hidden" name="pageRequest" value="postNote"></input>
			<span style="margin-left:40px;">Leave a message:</span> 
			<br />
			<input type="hidden" value="<%= storeOwner.getId() %>" name="ownerId"></input>
			<textarea name="noteText" style="width:700px; height: 100px;margin-left:40px;"></textarea>
			<input type="submit" value="Post Note" name="postNote"id="postNote" style="margin-left:40px;"></input>
			</form>
		<% } %>
		</div>
	</div>
	</div>
	</div>
	<div class="footer">
	<form action="/View" method="GET" >
	<input type="hidden" name="pageRequest" value="makeOffer"></input>
		<table class="swapTable" id="swapSection">
			<tr>
				<td colspan="2">
				<p class="headerText">Exchange Items</p>
				</td>
			</tr>
			<% if(session.getAttribute("user") != null){ %>
				<tr>
					<td>Their Items<input type="hidden" value="<%= storeOwner.getId() %>" name="userAccept"></input><input type="hidden" value="<%= storeOwner.getName() %>" name="ownerName"></input></td>
					<td>Your Items<input type="hidden" value="<%= ((UserBean)session.getAttribute("user")).getId() %>" name="userOffer"></input></td>
				</tr>
				<tr id="swapItems">
					<td id="theirContainer" style="border: #777 solid thin; width: 473px; padding: 10px; "><table id="theirItems"><tr></tr></table></td>
					<td id="myContainer" style="border: #777 solid thin; width: 473px; padding: 10px; "><table id="myItems"><tr></tr></table></td>
				</tr>
			<% } else { %>
				<tr>
					<td colspan="2">Please <a id="loginPopup" href="/Login.jsp" title="Login to SwapSpace!">login</a> to Swap.</td>
				</tr>
			<% } %>
		</table>
		<input type="submit" id="makeOffer" disabled="disabled" value="Make Offer!"></input>
	</form>	
	</div>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
</html>