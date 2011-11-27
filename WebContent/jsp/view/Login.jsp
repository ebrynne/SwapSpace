<div id="loginPage" >
<form id="loginForm" onSubmit="loginFunction(); return false;">
	<table class="loginTable">
		<tr>
			<td colspan="2" id="loginErrorMsg" style="font-size:10px; color:red;"></td>
		</tr>
		<tr>
			<td>Email:</td>
			<td><input type="text" id="loginEmail" name="loginEmail" size="30" maxlength="30"></input></td>
		</tr>
		<tr>
			<td>Password:</td>
			<td><input type="password" id="loginPassword" name="loginPassword" size="30" maxlength="15"></input></td>
		</tr>
	    <tr>
        	<td colspan="2" align="right"><input type="submit" value="Login" /></td>
        </tr>
        <tr>
        	<td colspan="2" align="left">Not a member? <a href="/Controller?pageRequest=register">Sign up here.</a></td>
        </tr>
	</table>
</form>
</div>