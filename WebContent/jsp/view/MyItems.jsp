<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<% if(session.getAttribute("user") == null){ response.sendRedirect("/Controller?pageRequest=home");} else{ 
		Item[] myItems = {};
		if(request.getAttribute("items") != null){
			myItems = (Item[])request.getAttribute("items");
		}
		int numItems = 0;
		if(myItems != null){
			numItems = myItems.length;
		}
		
	%>
	<head>
		<%@ page import="ss.beans.UserBean"%>
		<%@ page import="ss.beans.Item"%>
		<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
		<jsp:useBean id="resources" scope="application" class="ss.beans.ResourceBean" /> 
		<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
		<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
		<link rel="stylesheet" type="text/css" href="css/myItem.css"></link>
		<script src="js/jquery.js" type="text/javascript"></script>
		<script src="js/effects.core.js" type="text/javascript"></script>
		<script src="js/ajaxupload.js" type="text/javascript"></script>
		<script src="js/ui.core.js" type="text/javascript"></script>
		<script src="js/quickpagerdiv.jquery.js" type="text/javascript"></script>
		<script src="js/ajaxfileupload.js" type="text/javascript"></script>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>My Items</title>
		<script type="text/javascript">
		function removeItem(itemId){
			if(confirm('Are you sure you want to delete this item?')){
				$.ajax({
					url: "/User",
					type: "POST",
					data: "postType=removeItem&value=" +itemId,
					cache: false,
					success: function(j){
						if(jQuery.trim(j) == "1"){
							$("#item"+itemId).hide();
							$("#item"+itemId).removeClass();
						}
					}
				});
			}
		}

		function toggleSelected(id, isFocused){
			if(isFocused == "focus"){
				$("#desc"+id).addClass("selectedDesc");
			}else{
				$.ajax({
					url: "/User",
					type: "POST",
					data: "postType=itemDesc&itemId=" +id +"&itemDesc=" + $("#desc"+id).val(),
					cache: false,
					success: function(j){
						if(jQuery.trim(j) == "1"){
							$("#desc"+id).removeClass("selectedDesc");
						}
					}
				});
				$("#desc"+id).removeClass("selectedDesc");
			}
		}
		$(document).ready(function() {
			$(".pageme").quickPager( {
				pageSize: 4,
				currentPage: 1,
				pagerLocation: "after"
			});
			
			$('#newItemName').keyup(function (){
				if($('#newItemName').val().length > 4 && $("#newItemDescription").val().length > 25){
					$('#addNew').attr("disabled", false);
				}else{
					$('#addNew').attr("disabled", true);
				}
			}); 

			$('#newItemDescription').keyup(function (){
				if($('#newItemName').val().length > 4 && $("#newItemDescription").val().length > 25){
					$('#addNew').attr("disabled", false);
				}else{
					$('#addNew').attr("disabled", true);
				}
			}); 
		});
		
		</script>
	</head>
	<body>
		<jsp:include page="TopBar.jsp"></jsp:include>
		<div class="centerDiv pageNumFix">
		<h2>Upload a new Item</h2>
		<p>Here you can upload new items and edit your old ones. Please note that only the image and description of an item can be edited after uploading.</p>
		<form style="border: thin solid #777; padding: 5px;" action="/User" method="POST" enctype="multipart/form-data">
		<table>
			<tr style="padding:2px;">
				<td>Item Name:</td>
				<td><input type="text" class="inputBorder" name="newItemName"id="newItemName" maxlength="30"></input></td>
				<td></td>
			</tr>
			<tr>
				<td>Category:</td>
				<td><select class="inputBorder" name="newItemCategory" id="newItemCategory">
				<%
				for(int i = 0; i < resources.getCategories().length; i++){
				%>
					<option><%=resources.getCategories()[i] %></option>
				<%
				}
				
				%>
				</select></td>
				<td></td>
			</tr>
			<tr>
				<td style=" vertical-align:middle; ">Description:</td>
				<td><textarea name="newItemDescription" class="inputBorder" id="newItemDescription" cols="66" rows="5" style="overflow:hidden;"></textarea></td>
				<td></td>
			</tr>
			<tr>
				<td>Image:</td>
				<td><input class="inputBorder" name="newItemImage "id="newItemImage" type="file"></input></td>
				<td></td>
			</tr>
			<tr>
			<td></td>
			<td><input  type="submit" id="addNew" disabled="disabled" value="Add Item"></input></td>
			</tr>
		</table>
		<input type="hidden" name="uploadType" value="itemUpload"></input>
		<input type="hidden" name="pageRequest" value="myItems"></input>
		</form>
		
		
		<br /> <br />
		<h2>Current Items</h2>
		<div id="curItems" class="pageNumFix">
		<p>To edit the image or description of an item just click on them, they will be autosaved as you finish editing them. To delete, click the red X.</p>
		<div id="itemTable" class="pageme">
		<%
		if(numItems != 0){
			for(int i = 0; i < numItems; i++){
				Item curItem = myItems[i];
				System.out.println(curItem.getDescription().replaceAll("(<br >|&lt;br &gt;)", "\n") + "\n");
				String evenOddClass = i%2==0? "evenItemNoChng":"oddItemNoChng";
				String imgName ="/img/noimage.png";
				if(curItem.getImg() != null){
					if(!curItem.getImg().equals("")) imgName = "/img/item/"+curItem.getImg();
				}
				%>
	
				<div class="<%= evenOddClass %>" id="item<%=curItem.getId()%>">
					<script type="text/javascript">
					$(document).ready(function() {
						new AjaxUpload('#itemImg<%= curItem.getId() %>', {
					        action: 'FileUploadServlet',
					        data: {
					            uploadType : 'item',
						        itemId: <%= curItem.getId() %>
					        },
					        onChange : function(file, ext){
								$("#error<%= curItem.getId() %>").html("");
					        },
					        onSubmit : function(file , ext){
					           	if (! (ext && /^(jpg|png|jpeg|gif)$/.test(ext))){
									$("#error<%= curItem.getId() %>").html("<img src='/img/failure.png' class='inlineImage' alt='Invalid Image Type!' > Invalid image type (please use .jpg, .png, .jpeg, or .gif");
					            	return false;
					        	}else{
							        $("#itemImg<%= curItem.getId() %>").html("<img src='/img/loading.gif' class='itemImageSml' id></img>");
					        	}
					        },
					        onComplete: function(file, response){
					        	$("#error<%= curItem.getId() %>").html("");
						        $("#itemImg<%= curItem.getId() %>").html("<img src='/img/item/" + response+ "'  class='itemImageSml' id></img>");
					        }
						});
					});
					</script>
					<table>
					<tr>
					<td colspan="2"><p class="title"><b><%= curItem.getName() %></b></p><p class="errorSpace" id="error<%= curItem.getId() %>"></p></td>
					<td> <%= curItem.getCatagory() %></td>
					</tr>
					<tr>
					<td class="listImg" id="itemImg<%= curItem.getId() %>">
						<img src="<%= imgName %>" class="itemImageSml" id="itemImg<%= curItem.getId() %>"></img>
					</td>
					<td class="listDesc"><textarea class="<%= evenOddClass%> itemDesc" id="desc<%= curItem.getId() %>" rows="5" cols="66" onfocus="toggleSelected('<%=curItem.getId()%>', 'focus');" onblur="toggleSelected('<%=curItem.getId()%>', 'blur');"  style="overflow:hidden;"><%= curItem.getDescription().replaceAll("(<br >|&lt;br &gt;)", "\n") %></textarea></td>
					<td class="listDel" style="text-align: right;">
					<input type="image" src="/img/delete.png" onClick="removeItem(<%= curItem.getId() %>);"></input>
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
	<jsp:include page="BottomLinks.jsp"></jsp:include>
	</body>
	<%} %>
</html>