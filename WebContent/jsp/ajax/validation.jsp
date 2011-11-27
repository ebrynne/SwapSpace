<%@ page contentType="text/html; charset=iso-8859-1" language="java" %>
<%@ page import="ss.dao.DbDao" %>
<%
	DbDao dao = new DbDao();
	String param = request.getParameter("param");
	String val = request.getParameter("val");
	response.getWriter().write(dao.validateUserData(param, val ));
%>