package ss.controller;

import java.io.IOException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;

import ss.beans.UserBean;
import ss.dao.DbDao;

/**
 * Servlet implementation class RegisterServlet
 */
public class RegisterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public RegisterServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		DbDao dao = new DbDao();
		if(request.getSession().getAttribute("user") != null){
			UserBean user = (UserBean)request.getSession().getAttribute("user");
			request.setAttribute("dirtySwaps", dao.numDirtySwaps(user.getId()));
			request.setAttribute("dirtyMess", dao.numDirtyMess(user.getId()));
		}
		if(dao.registerUser(StringEscapeUtils.escapeXml(request.getParameter("username")),request.getParameter("password"), request.getParameter("email"), StringEscapeUtils.escapeXml(request.getParameter("location")))){
			RequestDispatcher dispatcher = request.getRequestDispatcher("/index.jsp?reg");
			dispatcher.forward( request, response);
		}else{
			RequestDispatcher dispatcher = request.getRequestDispatcher("/Register.jsp?registerError=true");
			dispatcher.forward( request, response);
		}	
	}

}
