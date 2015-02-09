package ss.controller;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ss.beans.ConversationBean;
import ss.beans.UserBean;
import ss.dao.DbDao;

/**
 * Servlet implementation class SearchServlet
 */
public class SearchServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String JSP_ROOT = "jsp/view/";

    private static final String CONVERSATIONS_JSP = JSP_ROOT + "/Conversations.jsp";

    /**
     * @see HttpServlet#HttpServlet()
     */
    public SearchServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String forward="";
		String searchType = request.getParameter("type");
		DbDao dao = new DbDao();
		UserBean user  = null;
		if(request.getSession().getAttribute("user") != null){
			user = (UserBean)request.getSession().getAttribute("user");
			request.setAttribute("dirtySwaps", dao.numDirtySwaps(user.getId()));
			request.setAttribute("dirtyMess", dao.numDirtyMess(user.getId()));
		}
		if(searchType != null){
			if(searchType.equals("user")){
				if(request.getParameter("locationRange")!=null) request.setAttribute("locationRange",request.getParameter("locationRange"));
				forward=JSP_ROOT + "/UserSearch.jsp";
			}else if(searchType.equals("item")){
				if(request.getParameter("locationRange")!=null) request.setAttribute("locationRange",request.getParameter("locationRange"));
				forward=JSP_ROOT + "/ItemSearch.jsp";
				
			}else if(searchType.equals("conversations")){
				if(user != null){
					String query = request.getParameter("query");
					ConversationBean [] convs = dao.searchConversations(query, user.getId());
					request.setAttribute("conversations", convs);
					forward=CONVERSATIONS_JSP;
				}else{
					forward=JSP_ROOT + "/index.jsp";
				}
			}
		}else{
			forward=JSP_ROOT + "/index.jsp";
		}
		RequestDispatcher view = request.getRequestDispatcher(forward);
		view.forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}

}
