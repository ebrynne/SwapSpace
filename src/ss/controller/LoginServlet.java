package ss.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import ss.beans.UserBean;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import ss.connection.ConnectionManager;
import ss.dao.DbDao;

/**
 * Servlet implementation class LoginServlet
 */
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    private UserBean user;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginServlet() {
        super();
    }
    
    public void init(){

    }

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String email = request.getParameter("email");
		String password = request.getParameter("password");
		String errorMsg = "";
		
		ConnectionManager cm = new ConnectionManager();
		Connection conn = cm.getConnection();
		DbDao dao = new DbDao(conn, cm);
		response.setContentType("text/html");
		PrintWriter out  = response.getWriter();
		
		
		if(conn != null){
			user = new UserBean();
			user = dao.login(email, password);
			
			if(user == null){
				errorMsg = "Invalid email or password";
			}
		}else{
			errorMsg = "Database connection error";
		}
		
		cm.closeConnection(conn);
		
		HttpSession ses = request.getSession(true);
		
		if(user != null){
			if(!user.getActive().equals("Active")){
				out.print("Account has been deactivated. Contact admin for details");
			}else{
				out.print("Success/" + user.getName());
				ses.setAttribute("user", user);
			}
		}else{
			out.print(errorMsg);
		}
		out.flush();
		out.close();
		
	}

}
