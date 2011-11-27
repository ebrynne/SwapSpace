package ss.controller;

import java.io.IOException;
import java.util.Enumeration;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;

import ss.beans.Item;
import ss.beans.Note;
import ss.beans.Review;
import ss.beans.UserBean;
import ss.dao.DbDao;

/**
 * Servlet implementation class ViewServlet
 */
public class ViewServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    private static final String STORE_JSP = "/ViewStore.jsp";
    private static final String OFFER_MADE_JSP = "/OfferMade.jsp";
    private static final String HOME_JSP = "/index.jsp";
    private static final String USER_REVIEW_JSP = "/UserReviews.jsp";
    private static final String USER_JSP = "/ViewUser.jsp";
    private static final String MESSAGES_JSP = "/Messages.jsp";
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ViewServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String forward=HOME_JSP;
		String requestParam = request.getParameter("pageRequest");
		UserBean user = (UserBean)request.getSession().getAttribute("user");
		if(requestParam != null){
				if (requestParam.equals("user")){
					DbDao dbdao = new DbDao();
					//Let it be known that it was HERE that I started commenting SS code. Badly.
					//Grab the userId and items of the user whose store we're viewing and add them to the request
					int userId =  Integer.parseInt(request.getParameter("user"));
					UserBean storeOwner = dbdao.getUser(userId);
					Item[] items = dbdao.getUserItems(userId);
					Note [] notes = dbdao.getNotes(userId);
					request.setAttribute("storeOwner", storeOwner);
					request.setAttribute("userItems", items);
					request.setAttribute("notes", notes);
					if(request.getSession().getAttribute("user") != null){;
						String favorite = dbdao.isFavorite(user.getId(), userId)? "favorite":"notFavorite";
						items = dbdao.getUserItems(user.getId());
						request.setAttribute("isFavorite", favorite);
						request.setAttribute("myItems", items);
					}
					forward = STORE_JSP;		
				}else if(requestParam.equals("makeOffer")){
					if(request.getSession().getAttribute("user") != null){
						//TODO: Check for success, else redirect to failure;
						DbDao dbdao = new DbDao();
						int storeId = Integer.parseInt(request.getParameter("userAccept"));
						int swapId = dbdao.createSwap();
						dbdao.addUserSwap(storeId, user.getId(), swapId, true);
						dbdao.addUserSwap(user.getId(), storeId, swapId, false);
					    Enumeration paramNames = request.getParameterNames();
					    while(paramNames.hasMoreElements()){
					    	String fieldName = (String) paramNames.nextElement();
					    	if(fieldName.startsWith("itemId")){
					    		int itemId = Integer.parseInt(request.getParameter(fieldName));
					    		dbdao.addItemToSwap(itemId, swapId);
					    	}
					    }
						forward = OFFER_MADE_JSP;
					}else{
						forward= HOME_JSP;
					}
				}else if(requestParam.equals("counterOffer")){
					if(request.getSession().getAttribute("user") != null){
						//TODO: Check for success, else redirect to failure;
						DbDao dbdao = new DbDao();
						int storeId = Integer.parseInt(request.getParameter("userAccept"));
						int swapId = Integer.parseInt(request.getParameter("swapId"));
					    Enumeration<String> paramNames = request.getParameterNames();
					    dbdao.removeItemsFromSwaps(swapId);
					    dbdao.swapDirty(swapId, storeId, true);
					    dbdao.changeSwapStatus(swapId, user.getId(), dbdao.wait);
					    dbdao.changeSwapStatus(swapId, storeId, dbdao.counter);
					    while(paramNames.hasMoreElements()){
					    	String fieldName = (String) paramNames.nextElement();
					    	if(fieldName.startsWith("itemId")){
					    		int itemId = Integer.parseInt(request.getParameter(fieldName));
					    		dbdao.addItemToSwap(itemId, swapId);
					    	}
					    }
						forward = OFFER_MADE_JSP;
					}else if(requestParam.equals("acceptOffer")){
						DbDao dbdao = new DbDao();
						int storeId = Integer.parseInt(request.getParameter("userAccept"));
						int swapId = Integer.parseInt(request.getParameter("swapId"));
					    dbdao.swapDirty(swapId, storeId, true);
					    dbdao.changeSwapStatus(swapId, user.getId(), dbdao.accept);
					    dbdao.changeSwapStatus(swapId, storeId, dbdao.accept);
					    request.setAttribute("swapId", swapId);
					    request.setAttribute("otherUser", storeId);
					    request.setAttribute("newSwap", true);
					    forward = MESSAGES_JSP;
					}else{
						forward = HOME_JSP;
					}
				}else if(requestParam.equals("viewUserReviews")){
					DbDao dao = new DbDao();
					int offset = 0;
					if(request.getParameter("offset") != null){
						offset = Integer.parseInt(request.getParameter("offset"));
					}
					int userId = Integer.parseInt(request.getParameter("viewUserId"));
					int numReviews = dao.getNumReviews(userId);
					UserBean viewUser = dao.getUser(userId);
					if(numReviews < offset*10) offset = 0;
					Review [] reviews = dao.getReviews(userId, offset *10);
					if(user!=null){
						String favorite = dao.isFavorite(user.getId(), userId)? "favorite":"notFavorite";
						request.setAttribute("isFavorite", favorite);
					}
					request.setAttribute("offset", offset);
					request.setAttribute("viewUser", viewUser);
					request.setAttribute("numReviews", numReviews);
					request.setAttribute("reviews", reviews);
					forward = USER_REVIEW_JSP;
				}else if(requestParam.equals("viewUser")){
					DbDao dao = new DbDao();
					int userId = Integer.parseInt(request.getParameter("viewUserId"));
					if(user!=null){
							String favorite = dao.isFavorite(user.getId(), userId)? "favorite":"notFavorite";
							request.setAttribute("isFavorite", favorite);
					}
					UserBean viewUser = dao.getUser(userId);
					request.setAttribute("viewUser", viewUser);
					forward = USER_JSP;
				}else if(requestParam.equals("postNote")){
					int ownerId = Integer.parseInt(request.getParameter("ownerId"));
					DbDao dbdao = new DbDao();
					String noteText = StringEscapeUtils.escapeXml(request.getParameter("noteText"));
					noteText = noteText.replaceAll("(\r\n|\r|\n|\n\r)", "<br \\>");
					int success = dbdao.insertNote(user.getId(), ownerId, noteText);
					UserBean storeOwner = dbdao.getUser(ownerId);
					Item[] items = dbdao.getUserItems(ownerId);
					Note [] notes = dbdao.getNotes(ownerId);
					request.setAttribute("storeOwner", storeOwner);
					request.setAttribute("userItems", items);
					request.setAttribute("notes", notes);
					if(request.getSession().getAttribute("user") != null){;
						String favorite = dbdao.isFavorite(user.getId(), ownerId)? "favorite":"notFavorite";
						items = dbdao.getUserItems(user.getId());
						request.setAttribute("isFavorite", favorite);
						request.setAttribute("myItems", items);
					}
					forward = STORE_JSP;
				}
				
		}
		
		RequestDispatcher view = request.getRequestDispatcher(forward);
		view.forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String postType = request.getParameter("postType");
		DbDao dao = new DbDao();
		UserBean user = (UserBean)request.getSession().getAttribute("user");
		if(request.getSession().getAttribute("user") != null){
			request.setAttribute("dirtySwaps", dao.numDirtySwaps(user.getId()));
			request.setAttribute("dirtyMess", dao.numDirtyMess(user.getId()));
		}
		int success = 3;
		if(postType.equals("addFave")){
			int faveId = Integer.parseInt(request.getParameter("faveId"));
			DbDao dbdao = new DbDao();
			success = dbdao.favoriteUser(user.getId(), faveId);
		}else if(postType.equals("removeFave")){
			int faveId = Integer.parseInt(request.getParameter("faveId"));
			DbDao dbdao = new DbDao();
			success = dbdao.unfavoriteUser(user.getId(), faveId);
		}else if(postType.equals("cleanSwap")){
			int swapId = Integer.parseInt(request.getParameter("swapId"));
			DbDao dbdao = new DbDao();
			success = dbdao.swapDirty(swapId, user.getId(), false);
		}
		response.setContentType("text/html");
		response.getWriter().print(success);
		response.getWriter().flush();
		response.getWriter().close();
	}

}
