package ss.controller;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ss.beans.UserBean;
import ss.beans.Item;
import ss.dao.DbDao;

/**
 * Servlet implementation class Controller
 */
public class Controller extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static String JSP_ROOT = "jsp/view/";
	private static String REGISTER_JSP = JSP_ROOT + "/Register.jsp";
	private static String HOME_JSP = JSP_ROOT + "/index.jsp";
	private static String RSS_JSP = JSP_ROOT + "/rss.jsp";
	private static String ADVANCED_SEARCH_JSP = JSP_ROOT + "/AdvancedSearch.jsp";
	private final String FAQS_JSP = JSP_ROOT + "/faqs.jsp";
	private final String CONTACT_JSP = JSP_ROOT + "/contactUs.jsp";
	private final String HELP_JSP = JSP_ROOT + "/help.jsp";

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String forward="";
		String requestParam = request.getParameter("pageRequest");
		DbDao dao = new DbDao();
		UserBean user = null;
		if(request.getSession().getAttribute("user") != null){
			user = (UserBean)request.getSession().getAttribute("user");
			request.setAttribute("dirtySwaps", dao.numDirtySwaps(user.getId()));
			request.setAttribute("dirtyMess", dao.numDirtyMess(user.getId()));
		}
		if(requestParam != null){
			if (requestParam.equals("register")){
				forward = REGISTER_JSP;
			} else if (requestParam.equals("home")){
				if(user != null){
					UserBean [] faveUsers = dao.getFaveUsers(user.getId());
					Item [] faveUserItems = dao.getFaveUserItems(faveUsers);
					Item [] faveSearchItems = dao.getFaveSearchItems(user.getId());
					String [] faveSearches = dao.getFaveSearches(user.getId());
					String news = dao.getNews();
					request.setAttribute("faveUsers", faveUsers);
					request.setAttribute("faveSearchItems", faveSearchItems);
					request.setAttribute("faveUserItems", faveUserItems);
					request.setAttribute("faveSearches", faveSearches);
					request.setAttribute("news", news);
				}
				forward = HOME_JSP;
			} else if (requestParam.equals("logout")){
				request.getSession().removeAttribute("user");
				forward = HOME_JSP;
			}	else if(requestParam.equals("advancedSearch")){
				forward = ADVANCED_SEARCH_JSP;
			} else if(requestParam.equals("contactUs")){
				forward = CONTACT_JSP;
			} else if(requestParam.equals("faqs")){
				forward = FAQS_JSP;
			} else if (requestParam.equals("help")){
				forward = HELP_JSP;
			}
		}else if(request.getParameter("rss") != null){
			String guid = request.getParameter("rss");
			String type = request.getParameter("type");
			int userId = dao.getUserIdByGuid(guid);
			Item [] items = null;
			if(type.equals("user")){
				UserBean[] faveUsers = dao.getFaveUsers(userId);
				items = dao.getFaveUserItems(faveUsers);
			}else{
				items = dao.getFaveSearchItems(userId);
			}
			request.setAttribute("type", type);
			request.setAttribute("items", items);
			forward = RSS_JSP;
		}
		
		RequestDispatcher view = request.getRequestDispatcher(forward);
		view.forward(request, response);
	}
}
