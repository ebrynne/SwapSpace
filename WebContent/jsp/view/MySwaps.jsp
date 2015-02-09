<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<% if(session.getAttribute("user") == null){ response.sendRedirect("/Controller?pageRequest=home");} else{ 
%>
<%
	UserBean user = (UserBean)session.getAttribute("user");
	if(request.getAttribute("swaps") != null){
		Swap [] swaps = (Swap [])request.getAttribute("swaps");
%>
<head>
	<%@ page import="ss.beans.UserBean"%>
	<%@ page import="ss.beans.Item"%>
	<%@ page import="ss.beans.Swap"%>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>My Swaps</title>	
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
	<link rel="stylesheet" type="text/css" href="css/pageTab.css"></link>
	<link rel="stylesheet" type="text/css" href="css/jquery.rating.css"></link>
	<link rel="stylesheet" type="text/css" href="css/jquery.fancybox.css"></link>
	<script src="js/jquery.js" type="text/javascript"></script>
	<script src="js/effects.core.js" type="text/javascript"></script>
	<script src="js/ui.core.js" type="text/javascript"></script>
	<script src="js/quickpagerdiv.jquery.js" type="text/javascript"></script>
	<script src="js/ui.tabs.js" type="text/javascript"></script>
	<script src="js/ajaxupload.js" type="text/javascript"></script>
	<script src="js/jquery.MetaData.js" type="text/javascript" language="javascript"></script>
 	<script src="js/jquery.rating.js" type="text/javascript" language="javascript"></script>
 	<script src="js/jquery.rating.pack.js" type="text/javascript"></script>
 	<script type="text/javascript">
 		function tabNums(){
			num = $("#currentSwaps").children().children().children(".new").size();
			if(num > 0){
				$("#currentSwapsLink").html("<b>Current Swaps ("+num+")</b>");
			}else{
				$("#currentSwapsLink").html("Current Swaps");
			}
			num = $("#cancelledSwaps").children().children().children(".new").size();
			if(num > 0){
				$("#cancelledSwapsLink").html("<b>Cancelled Swaps ("+num+")</b>");
			}else{
				$("#cancelledSwapsLink").html("Cancelled Swaps");
			}
			num = $("#completedSwaps").children().children().children(".new").size();
			if(num > 0){
				$("#completedSwapsLink").html("<b>Completed Swaps ("+num+")</b>");
			}else{
				$("#completedSwapsLink").html("Completed Swaps");
			}
 		}

		function reviewUser(swapId){

			var rating = $(".star"+swapId+ ".star-rating-on");
			
			
			$.ajax({
				url: "/User",
				type: "POST",
				data: "postType=reviewUser&swapId=" + swapId + "&title=" + $("#title"+swapId).val() + "&reviewText=" + $("#reviewText" +swapId).val() + "&otherUser=" + $("#otherUser"+swapId).val() + "&rating=" + rating.length,
				cache: false,
				success: function(j){
					$.fancybox.close();
					if(jQuery.trim(j) == "1"){
						alert("Review submitted. Thank you!");
						$("#reviewRemove"+swapId).html("");
						$("#linkShift").css("padding-left","0");
					}else{
						alert("Review failed, try again later.");
					}
				}
			});
		}
 		
 		function toggleView(swapId){
			$("#hideSwap"+swapId).slideToggle("normal");
			$.ajax({
				url: "/View",
				type: "POST",
				data: "postType=cleanSwap&swapId=" + swapId,
				cache: false,
				success: function(j){
					
					if($("#new"+swapId).html() != null){
						var regex = new RegExp("[0-9]+", "g");
							var num = regex.exec($("#swapLink").html());
							if(num > 1){
								$("#swapLink").html("My Swaps(" + (num - 1) + ")");
							}else{
								$("#swapLink").html("My Swaps");
							}
						}
					$("#new"+swapId).remove();
					tabNums();
				}
			});
			if($("#viewText"+swapId).html() == "View"){
				$("#viewText"+swapId).html("");
			}else{
				$("#viewText"+swapId).html("View");
			}
 		}
 		function showHide(showHideVar, id){
			if(showHideVar == "show"){
				alert("asdf");
			}
 		}

 		function readyReview(swapId){
			if($("#title"+swapId).val().length > 5 && $("#reviewText"+swapId).val().length > 10){
				$("#reviewSubmit"+swapId).attr("disabled", false);
			}else{
				$("#reviewSubmit"+swapId).attr("disabled", true);
			}
 		}
 		
	 	$(document).ready(function() {
	 		$("#tabs").tabs();
	 		tabNums();
	 		<%for(int i=0; i<swaps.length; i++){
	 		if(swaps[i].getStatus().equals("review") || swaps[i].getStatus().equals("accept")){%>
	 			
	 			$('#title<%= swaps[i].getId()%>').keyup(function(){
					readyReview(<%= swaps[i].getId() %>);
				});

	 			$('#reviewText<%= swaps[i].getId()%>').keyup(function(){
					readyReview(<%= swaps[i].getId() %>);
				});
			<% }
			if(swaps[i].getStatus().equals("accept")){%>	
			$("a#reviewLink<%= swaps[i].getId()%>").fancybox({ 'zoomSpeedIn': 300, 'zoomSpeedOut': 300, 'overlayShow': true, 'hideOnOverlayClick': true, 'scrolling' : 'no', 'hideOnContentClick' : false,'autoDimensions':false, 'width': 550, 'height': 450  }); 
			<% }}%>

			$("#currentSwaps ").quickPager( {
				pageSize: 8,
				currentPage: 1,
				pagerLocation: "after"
			});

			$("#cancelledSwaps ").quickPager( {
				pageSize: 8,
				currentPage: 1,
				pagerLocation: "after"
			});

			$("#completedSwaps ").quickPager( {
				pageSize: 8,
				currentPage: 1,
				pagerLocation: "after"
			});
		 });
 	</script>
</head>
<body>
<jsp:include page="TopBar.jsp"></jsp:include>
<div class="centerDiv">

<div id="tabs">
	<ul>
		<li><a id="currentSwapsLink" href="#currentSwaps">Current Swaps</a></li>
		<li><a id="completedSwapsLink" href="#completedSwaps">Swap History</a></li>
		<li><a id="cancelledSwapsLink" href="#cancelledSwaps">Canceled Swaps</a></li>
	</ul>
	<div id="currentSwaps" style="padding:20px;">
		<%
			for(int i = 0; i < swaps.length; i++){
				Swap swap = swaps[i];
				if(swap.getStatus().equals("wait") || swap.getStatus().equals("counter") || swap.getStatus().equals("offer")){
					String status ="";
					if(swap.getStatus().equals("wait")) status = "Waiting for other user to respond";
					if(swap.getStatus().equals("counter")) status = "You have recieved a counter offer";
					if(swap.getStatus().equals("offer")) status = "You have recieved a swap offer";
					%>
					<div>
					<img src="/img/curvebartop.png" style="padding:0px; margin:0px;"></img>
					<div id="swap<%= swap.getId() %>" class="curveBoxFormat">
						<form action="/User" method="GET">
						<div id="viewSwap<%= swap.getId() %>" style="margin:0;padding:0;border:0;" onClick="toggleView(<%= swap.getId() %>, <%= user.getId() %>);">
						<% if(swap.isDirty() ){ %><div id="new<%= swap.getId() %>" class="new" style="float:left;"><b>NEW -  </b></div><% } %><b>Exchange With:</b>  <a href = "/View?pageRequest=user&user=<%=swap.getOtherUser()%>"><%= swap.getOtherName() %></a> 
						<div style="float:right"><b>Status:</b><%= status %></div>
						<div style="text-align:center; width: 780px; "  class="link"id="viewText<%=swap.getId() %>">View</div>
						</div>
						<div id="hideSwap<%= swap.getId() %>" class="hidden" style="margin:0;padding:0;border:0;">
						<table style="width: 785px; text-align:center;" id="swapSection">
							<tr>
								<td colspan="2">
								<p class="headerText">Exchange Items</p><input type="hidden" value="<%= swap.getId() %>" name="swapId"></input>
								</td>
							</tr>
								<tr>
									<td>Their Items<input type="hidden" value="<%= swap.getId() %>" name="swapId"></input></td>
									<td>Your Items</td>
								</tr>
								<tr id="swapItems">
									<td id="theirContainer" style="border: #777 solid thin; width: 350px; padding: 23px; ">
										<%
											Item [] swapItems = swap.getItems();
											int itemCount = 0;
											if(swapItems != null){
												for(int j = 0; j< swapItems.length; j++){
													Item item = swapItems[j];
													if(item.getOwnerId() != user.getId()){
														String imgName = "/img/noimage.png";
														if(item.getImg()!=null){
															if(!item.getImg().equals("")){
																imgName = "/img/item/" + item.getImg();
															}
														}
														itemCount++;
														%>
														<div class='swapItem swapItemColors' style="float: left; margin:8px; "><p><b><%= item.getName() %></b><br /><img class='itemImageSml' src='<%= imgName %>'></img></p><input type="hidden" name="itemNum<%= item.getId() %>" value="<%= item.getId() %>"></input></div>
														<%
													}
												}
											}
										%>
									</td>
									<td id="myContainer" style="border: #777 solid thin; width: 350px; padding: 23px; ">
												<%
												itemCount = 0;
												if(swapItems != null){
													for(int j = 0; j< swapItems.length; j++){
														Item item = swapItems[j];
														if(item.getOwnerId() == user.getId()){
															String imgName = "/img/noimage.png";
															if(item.getImg()!=null){
																if(!item.getImg().equals("")){
																	imgName = "/img/item/" + item.getImg();
																}
															}
															itemCount++;
															%>
															<div class='swapItem swapItemColors' style="float:left; margin: 8px; "><p><b><%= item.getName() %></b><br /><img class='itemImageSml' src='<%= imgName %>'></img></p><input type="hidden" name="itemNum<%= item.getId() %>" value="<%= item.getId() %>"></input></div>
															<%
														}
													}
												}
												%>
									</td>
								</tr>
						</table>
						<div style="margin:0;padding:0;border:0; width: 780px; text-align:center;">
							<input type="hidden" value="<%= swap.getId() %>" name="swapId"></input>
							<% if(swap.getStatus().equals("counter") || swap.getStatus().equals("offer")){ %><input name="accept" type="submit" value="Accept Offer"></input><%} %>
							<% if(swap.getStatus().equals("counter") || swap.getStatus().equals("offer")){ %><input name="counter" type="submit" value="Make Counter Offer"></input><%} %>
							<input name="cancel" type="submit" value="Cancel Swap"></input>
							
						</div>
						<div style="text-align:center; width: 780px;" class="link" id="hideText" onClick="toggleView(<%= swap.getId() %>);">Hide</div>
						</div>
						</form>
					</div>
					<img src="/img/curvebarbottom.png" style="padding:0px; margin:0px; margin-bottom:20px;"></img>
					</div>
					<%
				}
			}
		%>
	</div>
	<div id="completedSwaps">
		<%
			for(int i = 0; i < swaps.length; i++){
				Swap swap = swaps[i];
				if(swap.getStatus().equals("accept") || swap.getStatus().equals("review")){
					%>
					<div>
					<img onClick="toggleView(<%= swap.getId() %>);" src="/img/curvebartop.png" style="padding:0px; margin:0px;"></img>
					<div id="swap<%= swap.getId() %>" style="width: 784px; border-left: 3px solid green; border-right: 3px solid green; margin:0px; padding: 5px;">
						<div id="viewSwap<%= swap.getId() %>" style="margin:0;padding:0;border:0;" >
						<% if(swap.isDirty() ){ %><div id="new<%= swap.getId() %>" class="new" style="float:left;"><b>NEW -  </b></div><% } %><b>Exchange With:</b>  <a href = "/View?pageRequest=user&user=<%=swap.getOtherUser()%>"><%= swap.getOtherName() %></a>
						<div style="float:right" ><span onClick="toggleView(<%= swap.getId() %>);"><b>Status:  </b>Swap Accepted! Continue to </span><a href="User?swapId=<%= swap.getId() %>&userAccept=<%= swap.getOtherUser() %>&conversationCont=true">your conversation</a> <span onClick="toggleView(<%= swap.getId() %>);"> with your swap partner</span></div>
						<div  onClick="toggleView(<%= swap.getId() %>);" style="text-align:center; width: 780px;" class="link" id="viewText<%=swap.getId() %>">View</div>
						</div>
						<div id="hideSwap<%= swap.getId() %>" class="hidden" style="margin:0;padding:0;border:0;">
						<table style="width: 785px; text-align:center;" id="swapSection">
							<tr>
								<td colspan="2">
								<p class="headerText">Exchange Items</p><input type="hidden" value="<%= swap.getId() %>" name="swapId"></input>
								</td>
							</tr>
								<tr>
									<td>Their Items<input type="hidden" value="<%= swap.getId() %>" name="swapId"></input></td>
									<td>Your Items</td>
								</tr>
								<tr id="swapItems">
									<td id="theirContainer" style="border: #777 solid thin; width: 350px; padding: 23px; ">
										<%
											Item [] swapItems = swap.getItems();
											int itemCount = 0;
											if(swapItems != null){
												for(int j = 0; j< swapItems.length; j++){
													Item item = swapItems[j];
													if(item.getOwnerId() != user.getId()){
														String imgName = "/img/noimage.png";
														if(item.getImg()!=null){
															if(!item.getImg().equals("")){
																imgName = "/img/item/" + item.getImg();
															}
														}
														itemCount++;
														%>
														<div class='swapItem swapItemColors' style="float: left; margin:8px; "><p><b><%= item.getName() %></b><br /><img class='itemImageSml' src='<%= imgName %>'></img></p></div>
														<%
													}
												}
											}
										%>
									</td>
									<td id="myContainer" style="border: #777 solid thin; width: 350px; padding: 23px; ">
												<%
												itemCount = 0;
												if(swapItems != null){
													for(int j = 0; j< swapItems.length; j++){
														Item item = swapItems[j];
														if(item.getOwnerId() == user.getId()){
															String imgName = "/img/noimage.png";
															if(item.getImg()!=null){
																if(!item.getImg().equals("")){
																	imgName = "/img/item/" + item.getImg();
																}
															}
															itemCount++;
															%>
															<div class='swapItem swapItemColors' style="float:left; margin: 8px; "><p><b><%= item.getName() %></b><br /><img class='itemImageSml' src='<%= imgName %>'></img></p></div>
															<%
														}
													}
												}
												%>
									</td>
								</tr>
						</table>
						<div style="display:none;">
						<div  id="reviewBox<%= swap.getId() %>" >
							<div style="width: 550px; text-align:center;"><h2>Review User</h2></div>
							<br />
							<form style="width: 550px; height:400px;" id="reviewForm" onSubmit="reviewUser(<%=swap.getId() %>); return false;">
								<font style="font-size: 16px">Title: &nbsp; &nbsp;</font> <input type="text" name="title" id="title<%= swap.getId() %>"></input> &nbsp; &nbsp; &nbsp;<div style="float:right; padding-right: 50px;">
								<input name='star<%= swap.getId() %>' type='radio' class='star star<%= swap.getId() %> ' />
								<input name='star<%= swap.getId() %>' type='radio' class='star star<%= swap.getId() %> ' />
								<input name='star<%= swap.getId() %>' type='radio' class='star star<%= swap.getId() %> ' />
								<input name='star<%= swap.getId() %>' type='radio' class='star star<%= swap.getId() %> ' />
								<input name='star<%= swap.getId() %>' type='radio' class='star star<%= swap.getId() %> ' /></div>
								<br /><h3>Review Text:</h3>
								<div style="text-align:center; width: 550px;">
								<textarea id="reviewText<%= swap.getId() %>" style="height:300px; width:450px; font-family: Helvetica, Verdana, Georgia, sans-serif;"></textarea>
								<br />
								<br />
								<input type="submit" id="reviewSubmit<%= swap.getId() %>" value="Submit Review" disabled="disabled"></input>
								</div>							
							</form>
						</div>
						</div>
						<div style="margin:0;padding:0;border:0; width: 780px; text-align:center;">
						<form action="/User" method="GET">
							<input type="hidden" name="swapId" value="<%= swap.getId()%>"></input>
							<input type="hidden" id="otherUser<%= swap.getId() %>" name="userAccept" value="<%= swap.getOtherUser()%>"></input>
							<a id="linkShift<%=swap.getId() %>" href="/User?conversationCont=true&userAccept=<%= swap.getOtherUser()%>&swapId=<%= swap.getId()%>" <% if (!swap.getStatus().equals("review")){ %>style="margin-left: -55px;"<%} %>>Continue to Conversation</a>
							<span id="reviewRemove<%= swap.getId() %>"><% if (!swap.getStatus().equals("review")){ %>&nbsp; &nbsp; <img src="/img/logo.gif" style="height:24px; width:24px; padding-top:5px;"></img>&nbsp; &nbsp; 
							<a id="reviewLink<%= swap.getId() %>" href="#reviewBox<%=swap.getId() %>">Review this user.</a><% } %></span>
						</form>
						</div>
						<div style="text-align:center; width: 780px;" class="link" id="hideText" onClick="toggleView(<%= swap.getId() %>);">Hide</div>
						</div>
					</div>
					<img src="/img/curvebarbottom.png" style="padding:0px; margin:0px; margin-bottom:20px;"></img>
					</div>
					<%
				}
			}
		%>
	</div>
	<div id="cancelledSwaps">
		<%
			for(int i = 0; i < swaps.length; i++){
				Swap swap = swaps[i];
				if(swap.getStatus().equals("cancel")){
					%>
					<div>
					<img src="/img/curvebartop.png" style="padding:0px; margin:0px;"></img>
					<div id="swap<%= swap.getId() %>" style="width: 784px; border-left: 3px solid green; border-right: 3px solid green; margin:0px; padding: 5px;">
						<div id="viewSwap<%= swap.getId() %>" style="margin:0;padding:0;border:0;" onClick="toggleView(<%= swap.getId() %>);">
						<% if(swap.isDirty() ){ %><div id="new<%= swap.getId() %>" class="new" style="float:left;"><b>NEW -  </b></div><% } %><b>Exchange With:</b>  <a href = "/View?pageRequest=user&user=<%=swap.getOtherUser()%>"><%= swap.getOtherName() %></a>
						<div style="float:right"><b>Status:  </b>This swap was cancelled</div>
						<div style="text-align:center; width: 780px; " class="link"id="viewText<%=swap.getId() %>">View</div>
						</div>
						<div id="hideSwap<%= swap.getId() %>" class="hidden" style="margin:0;padding:0;border:0;">
						<table style="width: 785px; text-align:center;" id="swapSection">
							<tr>
								<td colspan="2">
								<p class="headerText">Exchange Items</p><input type="hidden" value="<%= swap.getId() %>" name="swapId"></input>
								</td>
							</tr>
								<tr>
									<td>Their Items<input type="hidden" value="<%= swap.getId() %>" name="swapId"></input></td>
									<td>Your Items</td>
								</tr>
								<tr id="swapItems">
									<td id="theirContainer" style="border: #777 solid thin; width: 350px; padding: 23px; ">
										<%
											Item [] swapItems = swap.getItems();
											int itemCount = 0;
											if(swapItems != null){
												for(int j = 0; j< swapItems.length; j++){
													Item item = swapItems[j];
													if(item.getOwnerId() != user.getId()){
														String imgName = "/img/noimage.png";
														if(item.getImg()!=null){
															if(!item.getImg().equals("")){
																imgName = "/img/item/" + item.getImg();
															}
														}
														itemCount++;
														%>
														<div class='swapItem swapItemColors' style="float: left; margin:8px; "><p><b><%= item.getName() %></b><br /><img class='itemImageSml' src='<%= imgName %>'></img></p></div>
														<%
													}
												}
											}
										%>
									</td>
									<td id="myContainer" style="border: #777 solid thin; width: 350px; padding: 23px; ">
												<%
												itemCount = 0;
												if(swapItems != null){
													for(int j = 0; j< swapItems.length; j++){
														Item item = swapItems[j];
														if(item.getOwnerId() == user.getId()){
															String imgName = "/img/noimage.png";
															if(item.getImg()!=null){
																if(!item.getImg().equals("")){
																	imgName = "/img/item/" + item.getImg();
																}
															}
															itemCount++;
															%>
															<div class='swapItem swapItemColors' style="float:left; margin: 8px; "><p><b><%= item.getName() %></b><br /><img class='itemImageSml' src='<%= imgName %>'></img></p></div>
															<%
														}
													}
												}
												%>
									</td>
								</tr>
						</table>
						<div style="text-align:center; width: 780px; "  class="link"id="hideText" onClick="toggleView(<%= swap.getId() %>);">Hide</div>
						</div>
					</div>
					<img src="/img/curvebarbottom.png" style="padding:0px; margin:0px; margin-bottom:20px;"></img>
					</div>
					<%
				}
			}
		%>
	</div>
</div>
<% } %>
</div>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
<% } %>
</html>