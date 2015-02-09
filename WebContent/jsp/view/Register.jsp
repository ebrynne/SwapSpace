<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Sign Up for Swap Space! </title>
	<link rel="stylesheet" type="text/css" href="css/genericStyles.css"></link>
	<script src="js/jquery.js" type="text/javascript"></script>
	<script type="text/javascript">

		function readySubmit(){
			if($('#mailCheck').attr('checked') && $('#passCheck').attr('checked') && $('#confCheck').attr('checked') && $('#userCheck').attr('checked') && 	$("#termCond:checked").val() != null){
				$('#regSubmit').attr("disabled", false);
			}else {
				$('#regSubmit').attr("disabled", true);

			}
		}

		function validPassword(){
			var password = $('#password').val();
			var passwordConf = $('#passwordConf').val();
				if(password != 0){
					if(password.length > 7){
						$('#validatePassword').html("<img src='/img/success.png' class='inlineImage' alt='Good Password!' >");
						$('#passCheck').attr('checked', true);
						readySubmit();
					}else{
						$('#validatePassword').html("<img src='/img/failure.png' class='inlineImage' alt='Password too short!' > Please use a password at least eight characters long");
						$('#passCheck').attr('checked', false);
						readySubmit();
					}
					if(passwordConf != 0){
						if(passwordConf == password){
							$('#validateConfPassword').html("<img src='/img/success.png' class='inlineImage' alt='Good Password!'>");
							$('#confCheck').attr('checked', true);
							readySubmit();
						}else{
							$('#validateConfPassword').html("<img src='/img/failure.png' class='inlineImage' alt='Passwords don't match!' > Please match your passwords");
							$('#confCheck').attr('checked', false);
							readySubmit();
						}
					}else{
						$('#validateConfPassword').html("Please match your passwords");
						$('#confCheck').attr('checked', false);
						readySubmit();
					}
				}else{
					$('#validatePassword').html("Your password must be at least eight characters long");
					$('#passCheck').attr('checked', false);
					readySubmit();
				}
			
			readySubmit();
		}
		
				
		$(document).ready(function(){	
			$("a#aTermsCond").fancybox({ 'zoomSpeedIn': 300, 'zoomSpeedOut': 300, 'overlayShow': true, 'hideOnOverlayClick': true, 'hideOnContentClick' : false,'autoDimensions':false, 'height': 450, 'width':600}); 

			
			$('#email').keyup(function(){
				var t = this;
				var valEmail = $('#validateEmail');	
				var pattern = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
				var email = $('#email').val();
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
											$('#mailCheck').attr('checked', true);
											readySubmit();
										}else if(jQuery.trim(j) == "2"){
											valEmail.html("<img src='/img/failure.png' class='inlineImage' alt='Email unavailable!'> This email is already in use.");
											$('#mailCheck').attr('checked', false);	
											readySubmit();
										}else{
											valEmail.html("<img src='/img/failure.png' class='inlineImage' alt='Email unavailable!'> Connection Error. Whoops!");
											$('#mailCheck').attr('checked', false);	
											readySubmit();											
										}
									}
								});		
							}, 200);
						}
					}else{
						valEmail.html("<img src='/img/failure.png' class='inlineImage' alt='Invalid Email!' >Please enter a valid email");
						$('#mailCheck').attr('checked', false);
						readySubmit();
					}
				}else{
					valEmail.html("");
					$('#mailCheck').attr('checked', false);
					readySubmit();
				}
				readySubmit();
				this.lastValue = this.value;
			});

			$('#password').keyup(function(){
				validPassword();
			});

			$('#passwordConf').keyup(function(){
				validPassword();
			});

			
			
			$('#username').keyup(function() {
				var t = this;
				var valUsername = $('#validateUsername');
				if($('#username').val().length > 3){
					if($('#username').val().length < 16){
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
											$('#userCheck').attr('checked', true);
											readySubmit();
										}else if(jQuery.trim(j) == "2"){
											valUsername.html("<img src='/img/failure.png' class='inlineImage' alt='Username unavailable!'> This username is unavailable");
											$('#userCheck').attr('checked', false);	
											readySubmit();
										}
									}
								});		
							}, 200);
						}
					}else{
						$('#validateUsername').html("<img src='/img/failure.png' class='inlineImage' alt='Username too long!' > Please use a username at most 15 characters long.");
						$('#userCheck').attr('checked', false);
						readySubmit();
					}
				}else{
					$('#validateUsername').html("<img src='/img/failure.png' class='inlineImage' alt='Username too short!' > Please use a username at least 4 characters long.");
					$('#userCheck').attr('checked', false);
					readySubmit();
				}
				readySubmit();
				this.lastValue = this.value;
			});
			readySubmit();
		});

	</script>
</head>
<body>
<jsp:include page="TopBar.jsp"></jsp:include>
<div class="centerDiv">
<div id="error"><%if (!(request.getParameter("registerError")==null)){ out.print("An error has occured with your registration. Please try again."); } %>
</div>
<form method="post" action="/RegisterServlet">
	<table>
		<tr style="height:27px;">
			<td>*Username:</td>
			<td><input type="text" id="username" name="username"></input></td>
			<td id ="validateUsername"></td>
		</tr>
		<tr style="height:27px;">
			<td>*Password:</td>
			<td><input type="password" id="password" name="password"></input></td>
			<td id="validatePassword">Your password must be at least eight characters long</td>
		</tr>
		<tr style="height:27px;">
			<td>*Confirm Password:</td>
			<td><input type="password" id="passwordConf" name="passwordConf"></input></td>
			<td id="validateConfPassword">Please match your passwords</td>
		</tr>
		<tr style="height:27px;">
			<td>*Email Address:</td>
			<td><input type="text" id="email" name="email"></input></td>
			<td id ="validateEmail"></td>
		</tr>
		<!-- <tr style="height:27px;">
			<td>Postal Code/Zip Code</td>
			<td><input type="text" name="location"></input></td>
			<td><i>While this is not required, it allows us to provide you with location sensitive results.</i></td>
		</tr> -->
		<tr>
			<td colspan="3">By checking this checkbox, I agree to the <a href="jsp/view/TermsConds.jsp" id="aTermsCond">terms and conditions of service.</a>&nbsp;&nbsp;&nbsp; <input id="termCond" onClick="readySubmit();" type="checkbox"></input></td>
		</tr>
		<tr >
			<td><input type="submit" id="regSubmit" value="Register"></td>
			<td></td>
			<td></td>
		</tr>
	</table>
</form>
</div>
<input type="checkbox" id="userCheck" style="display: none;" disabled="disabled"></input>
<input type="checkbox" id="passCheck" style="display: none;" disabled="disabled"></input>
<input type="checkbox" id="confCheck" style="display: none;" disabled="disabled"></input>
<input type="checkbox" id="mailCheck" style="display: none;" disabled="disabled"></input>
<jsp:include page="BottomLinks.jsp"></jsp:include>
</body>
</html>