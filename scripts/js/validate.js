
		$(document).ready(function(){

			var email = $('#email').val();
			$('#email').keyUp(function(){
				if(email != 0){
					if(validEmail(email)){
						$('#validateEmail').html("<img src='/img/success.png' class='inlineImage' alt='Valid Email!' ><img>");
					}else{
						$('#validateEmail').html("<img src='/img/failure.png' class='inlineImage' alt='Invalid Email!' ><img> Please enter a valid email");
					}
				}else{
					$('#validateEmail').html("");
				}
			});

			var password = $('#password').val();
			$('#password').keyUp(function(){
				if(password != 0){
					if(password.length < 8){
						$('#validatePassword').html("<img src='/img/success.png' class='inlineImage' alt='Good Password!' ><img>");
					}else{
						$('#validatePassword').html("<img src='/img/failure.png' class='inlineImage' alt='Password too short!' ><img> Please use a password at least eight characters long");
					}
				}else{
					$('#validatePassword').html("Your password must be at least eight characters long");
				}
			});

			var passwordConf = $('#passwordConf').val();
			$('#passwordConf').keyUp(function(){
				if(passwordConf != 0 && password != 0){
					if(passwordConf == password){
						$('#validateConfPassword').html("<img src='/img/success.png' class='inlineImage' alt='Good Password!' ><img>");
					}else{
						$('#validateConfPassword').html("<img src='/img/failure.png' class='inlineImage' alt='Password too short!' ><img> Please match your passwords");
					}
				}else{
					$('#validateConfPassword').html("");
				}
			});
			
			var valUsername = $('#validateUsername');
			$('#username').keyup(function() {
				var t = this;

				if(this.value != this.lastValue){
					if(this.timer) this.clearTimer();
					valUsername.removeClass('error').html('<img src="img/loading.gif" height="16" width="16">');
					this.timer = setTimeout( function(){
						$.ajax({
							url: '/jsp/ajax/validation.jsp',
							data: '?param=username&val='+ t.value,
							dataType: 'json',
							type = 'post',
							success: function(j){
								valUsername.html(j.msg);
							}
						});		
					}, 200);
				}

				this.lastValue = this.value;
			});
			
		});

		if(session.getAttribute("registerError")){
			$('#error').html("An error occured during registration. Please try again.");
		}
		function validEmail(email){
			var pattern = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
			return pattern.test(email);
		}
		