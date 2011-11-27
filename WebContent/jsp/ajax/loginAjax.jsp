<%@page import="java.sql.Connection" %>
<%@page import="ss.connection.ConnectionManager" %>
<%@page import="ss.beans.UserBean" %>
<%@page import="ss.dao.DbDao" %>
<%
	String userName = request.getParameter("username");
	String password = request.getParameter("password");
	String errorMsg = "";
	UserBean user = null;
	ConnectionManager cm = new ConnectionManager();
	Connection conn = cm.getConnection();
	DbDao dao = new DbDao(conn, cm);
	response.setContentType("text/html");
	
	
	if(conn != null){
		user = new UserBean();
		user = dao.login(userName, password);
		
		if(user == null){
			errorMsg = "Invalid username or password";
		}
	}else{
		errorMsg = "Database connection error";
	}
	
	cm.closeConnection(conn);
	
	HttpSession ses = request.getSession(true);
	
	if(user != null){
		if(!user.getActive().equals("Active")){
			%>
				<div class="error">Account has been deactivated. Contact admin for details</div>
				<jsp:include page="/jsp/view/Login.jsp"></jsp:include>
			<%
		}else{
		%>
			<jsp:include page="/jsp/view/AccountLinks.jsp"></jsp:include>
		<%
			out.print("Success");
			ses.setAttribute("user", user);
		}
	}else{
		%>
			<div class="error"><%= errorMsg %></div>
			<jsp:include page="/jsp/view/Login.jsp"></jsp:include>
		<%
	}
	response.getWriter().write("I got here!");
%>