<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<% if(session.getAttribute("user") == null){ response.sendRedirect("/Controller?pageRequest=home");} else{ %>
<head>
	<%@ page import="ss.beans.SearchBean"%> 
	<%@ page import="ss.beans.UserBean"%>
	<%@ page import="ss.utilities.LocationUtilities"%>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Account Settings</title>
	<jsp:useBean id="searchBean" scope="session" class="ss.beans.SearchBean"></jsp:useBean>
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<link rel="stylesheet" type="text/css" href="css/ui.all.css"></link>
	<link rel="stylesheet" type="text/css" href="css/pageTab.css"></link>
	<link rel="stylesheet" type="text/css" href="css/jquery.rating.css"></link>
	<!-- <script src="js/jquery.js" type="text/javascript"></script>-->
	<script src="http://code.jquery.com/jquery-1.8.3.js"></script>
	<!-- <script src="js/effects.core.js" type="text/javascript"></script> -->
	<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>	
	<!--  <script src="js/ui.core.js" type="text/javascript"></script> -->
	<!-- <script src="js/quickpagertable.jquery.js" type="text/javascript"></script>
	<script src="js/ui.tabs.js" type="text/javascript"></script>
	<script src="js/jquery.MetaData.js" type="text/javascript" language="javascript"></script> -->
 	<script src="js/jquery.rating.js" type="text/javascript" language="javascript"></script>
	<script src="js/ajaxupload.js" type="text/javascript"></script>
	
	<script type="text/javascript">
	function validNewPassword(){
		var password = $('#password').val();
		var passwordConf = $('#passwordConf').val();
		if(password != 0){
			if(password.length > 7){
				$('#validatePassword').html("<img src='/img/success.png' class='inlineImage' alt='Good Password!' >");
				$('#submitPassChange').attr("disabled", false);
			}else{
				$('#validatePassword').html("<img src='/img/failure.png' class='inlineImage' alt='Password too short!' > Please use a password at least eight characters long");
				$('#submitPassChange').attr("disabled", true);
			}
			if(passwordConf != 0){
				if(passwordConf == password){
					$('#validateConfPassword').html("<img src='/img/success.png' class='inlineImage' alt='Good Password!'>");
					$('#submitPassChange').attr("disabled", false);
				}else{
					$('#validateConfPassword').html("<img src='/img/failure.png' class='inlineImage' alt='Passwords don't match!' > Please match your passwords");
					$('#submitPassChange').attr("disabled", true);
				}
			}else{
				$('#validateConfPassword').html("Please match your passwords");
				$('#submitPassChange').attr("disabled", true);
			}
		}else{
			$('#validatePassword').html("Your password must be at least eight characters long");
			$('#submitPassChange').attr("disabled", true);
		}
	}	

	function unfavorite(userId){
		if(confirm('Are you sure you want to remove this user?')){
			$.ajax({
				url: "/User",
				type: "POST",
				data: "postType=unfavorite&value=" +userId,
				cache: false,
				success: function(j){
					if(jQuery.trim(j) == "1"){
						$("#faveUser"+userId).hide();
						$("#faveUser"+userId).removeClass();
					}
				}
			});
		}
	}

	function unfavoriteSearch(searchTerm, i){
		if(confirm('Are you sure you want to remove this favorite search?')){
			$.ajax({
				url: "/User",
				type: "POST",
				data: "postType=removeFaveSearch&searchTerm=" +searchTerm,
				cache: false,
				success: function(j){
					if(jQuery.trim(j) == "1"){
						$("#faveSearch"+i).hide();
						$("#faveSearch"+i).removeClass();
					}
				}
			});
		}
	}
	function addFaveSearch(){
		var searchNum =$("#newSearchNum").val();
		var searchTerm =$("#newSearchTerm").val();
		var style = (searchNum%2==0)? "listEven" : "listOdd";
		$.ajax({
			url: "/User",
			type: "POST",
			data: "postType=addFaveSearch&searchTerm=" +searchTerm,
			cache: false,
			success: function(j){
				if(jQuery.trim(j) == "1"){
					$("#newSearchNum").val(searchNum+1);
					$("#faveSearchDiv").append("<div class='" + style + " faveSearch' id='faveSearch" + searchNum + "'><div class='faveSearchTerm'>"+ searchTerm +"</div><div class='faveSearchRemove' onClick=\"unfavoriteSearch('" + searchTerm +"', " + searchNum + ")\">Remove</div></div>");
				}
			}
		});

	}
	function submitChange(param, val, validate){
		$.ajax({
			url: "/User",
			type: "POST",
			data: "postType=changeUserProperty&param=" + param + "&value=" +$(val).val(),
			cache: false,
			success: function(j){
				if(param == "password"){
					if(jQuery.trim(j) == "1"){
						$("#passChangeMsg").html("<img src='/img/success.png' class='inlineImage' alt='Password Changed!'> Password successfuly changed");
					}else if(jQuery.trim(j) == "2"){
						$("#passChangeMsg").html("<img src='/img/failure.png' class='inlineImage' alt='Incorrect Password!'> Incorrect password. Please reenter your old password and try again.");
					}else{
						$("#passChangeMsg").html("<img src='/img/failure.png' class='inlineImage' alt='Database Connection Error!'> Connection Error. Whoops!");
					}
				}else{
					if(jQuery.trim(j) == "1"){
						$(validate).html("<img src='/img/success.png' class='inlineImage' alt='Change Success!'> Successfuly changed " + param + "!");
					}else if(jQuery.trim(j) == "2"){
						$(validate).html("<img src='/img/failure.png' class='inlineImage' alt='Change Failed!'> Changing " + param +" failed.");
					}else{
						$(validate).html("<img src='/img/failure.png' class='inlineImage' alt='Changed Failed'> Connection Error. Whoops!");
					}
				}
			}
		});		
	}
	
		$(document).ready(function() {
			$(".pageme ").quickPager( {
				pageSize: 8,
				currentPage: 1,
				pagerLocation: "after"
			});

			new AjaxUpload('#changeImage', {
		        action: 'FileUploadServlet',
		        data: {
		            uploadType : 'user'
		        },
		        onChange : function(file, ext){
					$("#imgError").hide();
		        },
		        onSubmit : function(file , ext){
		           	if (! (ext && /^(jpg|png|jpeg|gif)$/.test(ext))){
						$("#imgError").show();
		            	return false;
		        	}else{
						$("#imgLoad").show();
		        	}
		        },
		        onComplete: function(file, response){
			        $("#curImage").html("<img src='/img/user/" + response+ "'  class='userImageSml'></img>");
		        	$("#imgLoad").hide();
		        }
			});
			
			$("#triggerName").data("target", {content: "#contentName", label: "#usernameChange"});
			$("#triggerPass").data("target", {content: "#contentPass", label: "#passChange"});
			$("#triggerLocation").data("target", {content: "#contentLocation", label: "#locationChange"});
			$("#triggerEmail").data("target", {content: "#contentEmail", label: "#emailChange"});
			$("#triggerFaveUsers").data("target", {content: "#contentFaveUsers", label: "#FaveUsersChange"});
			$("#triggerFaveStores").data("target", {content: "#contentFaveStores", label: "#FaveStoresChange"});
			$("#drawerName").data("target", {content: "#contentName", label: "#usernameChange"});
			$("#drawerPass").data("target", {content: "#contentPass", label: "#passChange"});
			$("#drawerEmail").data("target", {content: "#contentEmail", label: "#emailChange"});
			$("#drawerFaveUsers").data("target", {content: "#contentFaveUsers", label: "#faveUsersChange"});
			$("#drawerFaveStores").data("target", {content: "#contentFaveStores", label: "#faveStoresChange"});
			$("#drawerLocation").data("target", {content: "#contentLocation", label: "#locationChange"});
			$("#triggerImage").data("target", {content: "#contentImage", label: "#imageChange"});
			$("#drawerImage").data("target", {content: "#contentImage", label: "#imageChange"});
			$("#drawerDescription").data("target", {content: "#contentDescription", label: "#descriptionChange"});
			$("#triggerDescription").data("target", {content: "#contentDescription", label: "#descriptionChange"});
			$("#drawerLookingFor").data("target", {content: "#contentLookingFor", label: "#lookingForChange"});
			$("#triggerLookingFor").data("target", {content: "#contentLookingFor", label: "#lookingForChange"});
			
			$('#triggerImage,#triggerLookingFor,#drawerLookingFor,#drawerDescription,#triggerDescription,#drawerImage,#triggerName,#triggerPass,#triggerLocation,#triggerEmail,#triggerFaveUsers,#triggerFaveStores,#drawerName,#drawerPass,#drawerEmail,#drawerLocation,#drawerFaveUsers,#drawerFaveStores').click(function() {
			    var content = $(this).data("target").content;
			    $(content).slideToggle("fast");
			    var change = $(this).data("target").label;
			    if($(change).html() == "Change"){
				    $(change).html("Done");
			    }else{
					$(change).html("Change");
			    }
			});

		    $("#tabs").tabs();

		    $('#password').keyup(function(){
				validNewPassword();
			});

			$('#passwordConf').keyup(function(){
				validNewPassword();
			});
		    $('#newUsername').keyup(function() {
				var t = this;
				var valUsername = $('#validateUsername');
				if($('#newUsername').val().length > 3){
					if($('#newUsername').val().length < 16){
						if(this.value != this.lastValue){
							if (this.timer) clearTimeout(this.timer);
							valUsername.html('<img src="img/loading.gif" height="16" width="16">');
							this.timer = setTimeout( function(){
								$.ajax({
									url: "/jsp/ajax/validation.jsp",
									type: "POST",
									data: "param=username&val=" +t.value,
									cache: false,
									success: function(j){
										if(jQuery.trim(j) == "1"){
											valUsername.html("<img src='/img/success.png' class='inlineImage' alt='Username available!'> This username is available");
											$('#submitUsernameChange').attr("disabled", false);
										}else if(jQuery.trim(j) == "2"){
											valUsername.html("<img src='/img/failure.png' class='inlineImage' alt='Username unavailable!'> This username is unavailable");
											$('#submitUsernameChange').attr("disabled", true);
										}
									}
								});		
							}, 200);
						}
					}else{
						$('#validateUsername').html("<img src='/img/failure.png' class='inlineImage' alt='Username too long!' > Please use a username at most 15 characters long.");
						$('#submitUsernameChange').attr("disabled", true);
					}
				}else{
					$('#validateUsername').html("<img src='/img/failure.png' class='inlineImage' alt='Username too short!' > Please use a username at least 4 characters long.");
					$('#submitEmailChange').attr("disabled", true);
				}
				this.lastValue = this.value;
			});

		    $('#newEmail').keyup(function(){
				var t = this;
				var valEmail = $('#validateEmail');	
				var pattern = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
				var email = $('#newEmail').val();
				if(email != 0){
					if(pattern.test(email) && email.length > 6){
						if(this.value != this.lastValue){
							if (this.timer) clearTimeout(this.timer);
							valEmail.html('<img src="img/loading.gif" height="16" width="16">');
							this.timer = setTimeout( function(){
								$.ajax({
									url: "/jsp/ajax/validation.jsp",
									type: "POST",
									data: "param=email&val=" +t.value,
									cache: false,
									success: function(j){
										if(jQuery.trim(j) == "1"){
											valEmail.html("<img src='/img/success.png' class='inlineImage' alt='Email available!'>");
											$('#submitEmailChange').attr("disabled", false);
										}else if(jQuery.trim(j) == "2"){
											valEmail.html("<img src='/img/failure.png' class='inlineImage' alt='Email unavailable!'> This email is already in use.");
											$('#submitEmailChange').attr("disabled", true);
										}else{
											valEmail.html("<img src='/img/failure.png' class='inlineImage' alt='Email unavailable!'> Connection Error. Whoops!");
											$('#submitEmailChange').attr("disabled", true);										
										}
									}
								});		
							}, 200);
						}
					}else{
						valEmail.html("<img src='/img/failure.png' class='inlineImage' alt='Invalid Email!' >Please enter a valid email");
						$('#submitEmailChange').attr("disabled", true);
					}
				}else{
					valEmail.html("");
					$('#submitEmailChange').attr("disabled", true);
				}
				this.lastValue= this.value;
			});
		});
		$(function() {
	        $( "#tabs" ).tabs();
	    });
	</script>
	<% if(searchBean.getLocation() == null) searchBean.autoSetLocation(request); %>
	<% LocationUtilities locUtils = new LocationUtilities(searchBean.getLocation()); %>
</head>
<body>
<jsp:include page="TopBar.jsp"></jsp:include>
<div class="centerDiv">
<div id="tabs">
	<ul>
		<li><a href="#userSettings">User Settings</a></li>
		<li><a href="#favorites">Favorites</a></li>
		<li><a href="#notifications">Notifications</a></li>
	</ul>
	<div id="userSettings">		
		<div id="triggerPass"><div class="leftAlign">Password</div><div class="rightAlign"><span id="passChange" class="linkInactive">Change</span></div></div>
		<br /><hr class="dimitriStandard" />
		<div id="contentPass" class="hidden">
			<div class="accountSettingsAlignFix">
				Here you can change your password to anything greather than 8 characters and less than 15.<br />
				You will need your old password to confirm.<br /><br />
				<table >
					<tr style="height:23px;">
						<td>New Password:</td>
						<td><input type="password" class="inputBorder" id="password" maxlength="15"></input></td>
						<td id="validatePassword"></td>
					</tr>
					<tr style="height:23px;">
						<td>Confirm New Password:</td>
						<td><input type="password" class="inputBorder" id="passwordConf" maxlength="15"></input></td>
						<td id="validateConfPassword"></td>
					</tr>
					<tr style="height:23px;">
						<td>Old Password:</td>
						<td><input class="inputBorder" type="password" id="oldPassword"></input></td>
						<td></td>
					</tr>
					<tr>
						<td><input type="submit" id="submitPassChange" value="Change Password" disabled="true" onClick="submitChange('password', '#password', '#passChangeMsg')"></input></td>
						<td></td>
						<td id="submitPassChangeValid"></td>
					</tr>
				</table>
				<div id="passChangeMsg"></div>
			</div>
			<p class="center">
			<img id="drawerPass" src="/img/drawer.gif" style="display: inline;"></img>
			</p>
		</div>
		<br /><br />
		<div id="triggerLocation"><div class="leftAlign">Location Information</div><div class="rightAlign"><span id="locationChange" class="linkInactive">Change</span></div></div>
		<br /><hr class="dimitriStandard" />
		<div id="contentLocation" class="hidden">
			<div class="accountSettingsAlignFix">
			Providing your location will allow us to provide location sensitive results, ensuring the best possible experience during your stay at SwapSpace.<br /><br />
			<%--Location: <input type="text" class="inputBorder" id="newLocation" value="<%=((UserBean)session.getAttribute("user")).getLocation() %>" size="10" maxlength="10"></input> 
			<% if (searchBean.getLocation()[0] != -1){ 
			%>
				<img src="http://maps.google.com/maps/api/staticmap?center=<%= locUtils.getLatitude() %>,<%= locUtils.getLongitude() %>&zoom=12&size=600x250&sensor=false&maptype=roadmap&markers=color:red|label:A|<%= locUtils.getLatitude() %>,<%= locUtils.getLongitude() %>" alt="Your Location"></img>
			<% } %>
			<input type="submit" value="Change Location" id="submitLocationChange" onClick="submitChange('location', '#newLocation', '#locationMsg' );"></input>
			<div id="locationMsg"></div>--%>
			</div>
			<p class="center">
			<img id="drawerLocation" src="/img/drawer.gif" style="display: inline;"></img>
			</p>
		</div>
		<br /><br />
		<div id="triggerImage"><div class="leftAlign">Profile Picture</div><div class="rightAlign"><span id="imageChange" class="linkInactive">Change</span></div></div>
		<br /><hr class="dimitriStandard" />
		<div id="contentImage" class="hidden">
			<div class="accountSettingsAlignFix">
				Set your profile picture to any image under 500kb.
				<div id="changeImage">
					<div id="curImage">
					<%
					String imgName = "/img/noimage.png";
					if(((UserBean)session.getAttribute("user")).getImg() != null){
						if(!((UserBean)session.getAttribute("user")).getImg().equals("")) imgName = ((UserBean)session.getAttribute("user")).getImg();
					}
					%>
					<img src="/img/user/<%=imgName %>" class="userImageSml"></img>
					</div>
					<input type="submit" value="Choose Image" ></input>
				</div>
				<div id="imgError" class="hidden"><img src='/img/failure.png' class='inlineImage' alt='Upload Error' >Please use a file of type .jpg, .png, .jpeg, or .gif"</div>
				<div id="imgLoad" class="hidden"><img src="img/loading.gif"></img></div>
			</div>
			<p class="center">
			<img id="drawerImage" src="/img/drawer.gif"  style="display: inline;"></img>
			</p>
		</div>
		<br/><br/>
		<div id="triggerDescription"><div class="leftAlign">Description</div><div class="rightAlign"><span id="descriptionChange" class="linkInactive">Change</span></div></div>
		<br /><hr class="dimitriStandard" />
		<div id="contentDescription" class="hidden">
			<div class="accountSettingsAlignFix">
				Please enter a brief description of yourself that you would like to be seen by other people. If you really need to tell the world about your darling cat BoBo, this is the place to do it.<br /><br />
				Description:<br />
				<textarea  class="inputBorder" name="newUserDescription" id="newUserDescription" cols="66" rows="5" style="overflow:hidden;"><%= ((UserBean)session.getAttribute("user")).getDescription().replaceAll("(<br >|&lt;br &gt;)", "\n") %></textarea>
				<br /><input type="submit" id="submitDescriptionChange" value="Change Description" onClick="submitChange('description', '#newUserDescription', '#validateDescription');"></input>
				<div id="validateDescription"></div>
			</div>
			<p class="center">
			<img id="drawerDescription" src="/img/drawer.gif" style="display: inline;"></img>
			</p>
		</div>
		<br /><br />
		<div id="triggerLookingFor"><div class="leftAlign">Looking For Items</div><div class="rightAlign"><span id="lookingForChange" class="linkInactive">Change</span></div></div>
		<br /><hr class="dimitriStandard" />
		<div id="contentLookingFor" class="hidden">
			<div class="accountSettingsAlignFix">
				Here you can tell people what you're interested in, so hopefully you'll get fewer offers of vintage collections of used Q-Tips, unless that's what you're looking for.<br /><br />
				What are you interested in:<br />
				<textarea class="inputBorder" name="newLookingFor" id="newLookingFor" cols="66" rows="5" style="overflow:hidden;"><%= ((UserBean)session.getAttribute("user")).getLookingFor() %></textarea>
				<br /><input type="submit" id="submitLookingForChange" value="Change Your Interests" onClick="submitChange('lookingFor', '#newLookingFor', '#validateLookingFor');"></input>
				<div id="validateLookingFor"></div>
			</div>
			<p class="center">
			<img id="drawerLookingFor" src="/img/drawer.gif" style="display: inline;"></img>
			</p>
		</div>
	</div>
	<div id="favorites" style="text-align:center;">
		<div id="triggerFaveUsers"><div class="leftAlign">Favorite Users</div><div class="rightAlign"><span id="faveUsersChange" class="linkInactive">Change</span></div></div>
		<br /><hr class="dimitriStandard" />
		<div id="contentFaveUsers" class="hidden">
			<table class="pageme" style="width:800px;">
				<tbody class="mainBody">
				<% 
					UserBean[] faveUsers = (UserBean[])request.getAttribute("faveUsers");
					if(faveUsers.length == 0){
						%>
							<tr>
							<td class="noresults">
								<br />
								<br />
								No results found.
								<br />
								<br />
								<br />
							</td>
							</tr>
						<%
					}else{
						for(int i=0; i<faveUsers.length; i++){
							String userStyling = "";
							if(faveUsers[i].getActive().equals("Deactivated")){
								userStyling = "listDeactivated";
							}else if(i%2 ==0){
								userStyling = "listEven";
							}else{
								userStyling = "listOdd";
							}
						%>								
							<tr id="faveUser<%= faveUsers[i].getId() %>" class="<%= userStyling %>">
									<td><%=faveUsers[i].getName() %></td>
									<td><%=faveUsers[i].getLocation() %></td>
									<td>
									<div class="Clear">
									<%
									int checked = (int)(faveUsers[i].getRating() * 4);
									for(int j = 1; j<= 20; j++){
										if(j == checked){
											out.print("<input name='star" + faveUsers[i].getName() +"' type='radio' class='star {split:4}' value='" + String.valueOf(j) + "' disabled='disabled' checked='checked'/>");
										}else{
											out.print("<input name='star"+faveUsers[i].getName()+"' type='radio' class='star {split:4}' value='" +String.valueOf(j)+"' disabled='disabled'/>") ;										
										}
									}
									%>
									</div>
									</td>
									<td><input value="Unfavorite this user!" type="image" class="inlineImageMed" src="/img/minusHeart.png" onClick="unfavorite(<%= faveUsers[i].getId()%>);"></input></td>
							</tr>
						<%	
						}
					}
				%>
				</tbody>
				</table>
		</div>
		<br /><br />
		<div id="triggerFaveStores"><div class="leftAlign">Favorite Searches</div><div class="rightAlign"><span id="faveStoresChange" class="linkInactive">Change</span></div></div>
		<br /><hr class="dimitriStandard" />
		<div id="contentFaveStores" style="border: solid thin; padding-bottom:4px;" class="hidden">
			<div id="faveSearchDiv">
			<% 
				String[] faveSearches = new String[0];
				if(request.getAttribute("faveSearches")!=null){
					faveSearches = (String[])request.getAttribute("faveSearches");
				}
				int i =0;
				if(faveSearches!=null){
					for(i = 0; i< faveSearches.length; i++){
			%>
					<div class="<%= i%2==0?"listEven":"listOdd" %> faveSearch" id="faveSearch<%=i %>"><div class="faveSearchTerm"><%= faveSearches[i] %></div><div class="faveSearchRemove" onClick="unfavoriteSearch('<%=faveSearches[i] %>', <%= i %>)">Remove</div></div>
			<%
					}
				}
			%>
			</div>
			<br />
			<input type="text" length="40" id="newSearchTerm"></input><input type="hidden" value="<%= i+1 %>" id="newSearchNum"></input><input type="button" value="New Favorite Search" onClick="addFaveSearch()"></input>
		</div>		
	</div>
	<div id="notifications">
		Coming Soon!
	</div>
</div>
</div>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
<% } %>
</html>
