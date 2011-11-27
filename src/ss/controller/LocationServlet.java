package ss.controller;

import java.io.IOException;
import ss.dao.DbDao;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ss.beans.SearchBean;

public class LocationServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	//TestLoc?testLocation=true&testNum=50&range=50&size=small&table=testlocations3&type=postgres
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		//SearchBean searchBean = request.getSession().getAttribute("searchBean") == null ? new SearchBean() : (SearchBean)request.getSession().getAttribute("searchBean");
		//int testNum = Integer.parseInt(request.getParameter("testLocation"));
		if(request.getParameter("testLocation") != null){
			DbDao dao = new DbDao(request.getParameter("type"));
			dao.testSearches(Integer.parseInt(request.getParameter("testNum")), Integer.parseInt(request.getParameter("range")), request.getParameter("size"), request.getParameter("table"), request.getParameter("type"));
		}
	}
}
