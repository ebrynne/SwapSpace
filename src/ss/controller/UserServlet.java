package ss.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadBase;
import org.apache.commons.fileupload.RequestContext;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.servlet.ServletRequestContext;
import org.apache.commons.lang.StringEscapeUtils;

import ss.beans.ConversationBean;
import ss.beans.Item;
import ss.beans.MessageBean;
import ss.beans.Review;
import ss.beans.Swap;
import ss.beans.UniqueDBO;
import ss.beans.UserBean;
import ss.dao.DbDao;

/**
 * Servlet implementation class UserServlet
 */
public class UserServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String JSP_ROOT = "jsp/view/";

    private static final String ACCOUNT_JSP = JSP_ROOT + "/AccountSettings.jsp";
    private static final String HOME_JSP = JSP_ROOT + "/index.jsp";
    private static final String MY_ITEMS_JSP = JSP_ROOT + "/MyItems.jsp";
    private static final String MY_SWAPS_JSP = JSP_ROOT + "/MySwaps.jsp";
    private static final String COUNTER_JSP = JSP_ROOT + "/CounterOffer.jsp";
    private static final String ERROR_JSP = JSP_ROOT + "/Error.jsp";
    private static final String CONVERSATIONS_JSP = JSP_ROOT +  "/Conversations.jsp";
    private static final String MESSAGES_JSP = JSP_ROOT + "/Messages.jsp";
    private static final String REVIEW_JSP = JSP_ROOT + "/ReviewUser.jsp";
    
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UserServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String forward="";
		String requestParam = request.getParameter("pageRequest");
		DbDao dbdao = new DbDao();
		UserBean user = (UserBean)request.getSession().getAttribute("user");
		if(requestParam != null){
			if(request.getSession().getAttribute("user") != null){
					if (requestParam.equals("accountSettings")){
					int userId = user.getId();
					UserBean[] users = dbdao.getFaveUsers(userId);
					String [] faveSearches = dbdao.getFaveSearches(userId);
					request.setAttribute("faveSearches", faveSearches);
					request.setAttribute("faveUsers", users);
					forward = ACCOUNT_JSP;		
				}else if(requestParam.equals("myItems")){
					Item [] items = dbdao.getUserItems(user.getId());
					request.setAttribute("items", items);
					forward = MY_ITEMS_JSP;
				}else if(requestParam.equals("mySwaps")){
					Swap [] swaps = dbdao.getSwapsItemsForUsers(user.getId());
					request.setAttribute("swaps", swaps);
					forward = MY_SWAPS_JSP;
				}else if(requestParam.equals("conversations")){
					ConversationBean [] cons = dbdao.getConversations(user.getId());
					request.setAttribute("conversations", cons);
					forward = CONVERSATIONS_JSP;
				}else if(requestParam.equals("messages")){
					if(request.getParameter("conversationId") != null){
						MessageBean [] messages = dbdao.getMessages(Integer.parseInt(request.getParameter("conversationId")));
						request.setAttribute("messages", messages);
						dbdao.cleanConversation(Integer.parseInt(request.getParameter("conversationId")), user.getId());
						request.setAttribute("conversationId", Integer.parseInt(request.getParameter("conversationId")));
						forward = MESSAGES_JSP;
					}else{forward  = ERROR_JSP;}
				}else if(requestParam.equals("reviewUser")){
					int swapId = Integer.parseInt(request.getParameter("swapId"));
					int toReview = dbdao.checkReview(swapId, user.getId());
					request.setAttribute("reviewStatus", toReview);
					request.setAttribute("swapId", swapId);
					forward = REVIEW_JSP;
				}else{
					if(user != null){
						DbDao dao = new DbDao();
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
				}
					request.setAttribute("dirtySwaps", dbdao.numDirtySwaps(user.getId()));
					request.setAttribute("dirtyMess", dbdao.numDirtyMess(user.getId()));
			}else{
				if(user != null){
					DbDao dao = new DbDao();
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
			}
		}
		if(request.getSession().getAttribute("user") != null){
			//TODO: Make it check for the right user.
			if(request.getParameter("counter") != null){
				int swapId = Integer.parseInt(request.getParameter("swapId"));
				Enumeration parNames = request.getParameterNames();
				String parName = (String)parNames.nextElement();
				HashMap<String, String> offeredItems = new HashMap<String, String>();
				while(parNames.hasMoreElements()){
					parName = (String)parNames.nextElement();
					if(parName.contains("itemNum")){
						offeredItems.put(parName.replaceFirst("itemNum", ""), request.getParameter(parName));
					}
				}
				int ownerId =  dbdao.getOtherSwapUser(swapId, user.getId());
				if(ownerId == -1){
					forward = ERROR_JSP;
				}else{
					UserBean storeOwner = dbdao.getUser(ownerId);
					Item[] items = dbdao.getUserItems(ownerId);
					request.setAttribute("itemHash", offeredItems);
					request.setAttribute("storeOwner", storeOwner);
					request.setAttribute("storeItems", items);
					request.setAttribute("swapId", swapId);
					if(request.getSession().getAttribute("user") != null){;
						String favorite = dbdao.isFavorite(((UserBean)request.getSession().getAttribute("user")).getId(), ownerId)? "favorite":"notFavorite";
						items = dbdao.getUserItems(((UserBean)request.getSession().getAttribute("user")).getId());
						request.setAttribute("isFavorite", favorite);
						request.setAttribute("myItems", items);
					}
					forward = COUNTER_JSP;
				}
			}else if(request.getParameter("cancel") != null){
				int swapId = Integer.parseInt(request.getParameter("swapId"));
				dbdao.cancelSwap(swapId);
				Swap [] swaps = dbdao.getSwapsItemsForUsers(user.getId());
				request.setAttribute("swaps", swaps);
				forward = MY_SWAPS_JSP;
			}else if(request.getParameter("accept") != null){
				int swapId = Integer.parseInt(request.getParameter("swapId"));
				dbdao.acceptSwap(swapId);
				Swap [] swaps = dbdao.getSwapsItemsForUsers(user.getId());
				dbdao.setItemsSwapped(swapId);
				request.setAttribute("swaps", swaps);
				forward = MY_SWAPS_JSP;
			}else if(request.getParameter("conversationCont")!=null){
				int storeId = Integer.parseInt(request.getParameter("userAccept"));
				int swapId = Integer.parseInt(request.getParameter("swapId"));
				request.setAttribute("swapId", swapId);
			    request.setAttribute("otherUser", storeId);
			    boolean newSwapConv = dbdao.isNewSwapConv(swapId);
			    request.setAttribute("newSwap", newSwapConv?"true":"false");
			    if(!newSwapConv){
			    	MessageBean [] messages = dbdao.getMessages(dbdao.getConversationId(swapId));
					dbdao.cleanConversation(dbdao.getConversationId(swapId), user.getId());
			    	request.setAttribute("messages", messages);
			    }
			    forward = MESSAGES_JSP;
			}else if(request.getParameter("conversationNew")!=null){
				request.setAttribute("newConv", "true");
				UserBean users[] = dbdao.getFriends(user.getId());
				request.setAttribute("friends", users);
				forward = MESSAGES_JSP;
			}else if(request.getParameter("reviewUser")!=null){
				int swapId =  Integer.parseInt(request.getParameter("swapId"));
				int needsReview = dbdao.checkReview(swapId, user.getId());
				request.setAttribute("needsReview", needsReview==1? "true":"false");
				request.setAttribute("swapId", swapId);
				forward=REVIEW_JSP;
			}
			RequestDispatcher view = request.getRequestDispatcher(forward);
			view.forward(request, response);
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String postType = request.getParameter("postType");
		ServletContext context = getServletContext();
		RequestContext reqContext = new ServletRequestContext(request);
	    boolean isMultipart = FileUploadBase.isMultipartContent(reqContext);
		int success = 3;
		UserBean user = (UserBean)request.getSession().getAttribute("user");
		String forward = HOME_JSP;
		if(user != null){
	    	if(isMultipart){
	    		String uploadType = "";
	    	    String itemName = "";
	    	    String itemDesc = "";
	    	    String itemCate = "";
	    	    FileItem imgFile = null;
		    	FileItemFactory factory = new DiskFileItemFactory();
		        ServletFileUpload upload = new ServletFileUpload(factory);
				try{
					List reqData = upload.parseRequest(request);
					Iterator reqIt = reqData.iterator();
					while(reqIt.hasNext()){
						FileItem fi = (FileItem)reqIt.next();
						if(fi.isFormField()){
							if(fi.getFieldName().equals("uploadType")) uploadType= fi.getString();
							if(fi.getFieldName().equals("newItemDescription")) itemDesc = fi.getString();
							if(fi.getFieldName().equals("newItemName")) itemName = fi.getString();
							if(fi.getFieldName().equals("newItemCategory")) itemCate = fi.getString();
						}
						if(!fi.isFormField()){
							if(fi.getName()!=null){
								if(!fi.getName().equals("")){
									imgFile = fi;
								}
							}
						}
					}
					
					itemDesc = StringEscapeUtils.escapeXml(itemDesc);
					System.out.println(itemDesc);
					itemDesc = itemDesc.replaceAll("(\r\n|\r|\n|\n\r)", "<br \\>");
					itemName = StringEscapeUtils.escapeXml(itemName);
					
					Calendar now = Calendar.getInstance();
					DbDao db = new DbDao();
					String imageName = "";
					if(imgFile != null){
						imageName = now.getTimeInMillis() + user.getName() + imgFile.getName();
					}
					if(uploadType.equals("itemUpload")){
						File rootDir = new File(context.getRealPath("/img/item")) ;
						if(db.addItem(user.getId(), imageName, itemName, itemDesc, itemCate) == 1){
							if(imageName != ""){
								File saveLoc = new File(rootDir, imageName);
								imgFile.write(saveLoc);
							}
						}
						DbDao dbdao = new DbDao();
						Item [] items = dbdao.getUserItems(user.getId());
						request.setAttribute("items", items);
						RequestDispatcher view = request.getRequestDispatcher(MY_ITEMS_JSP);
						view.forward(request, response);
					}
				}catch(Exception e){
					System.out.println("Error during file upload");
					e.printStackTrace();
				}
		    }else if(postType!= null){
				if(postType.equals("changeUserProperty")){
					String param = request.getParameter("param");
					String value = request.getParameter("value");
					DbDao dbdao = new DbDao();
					if(param.equals("password")){
						if(dbdao.checkPass(value, user.getId())){
							success = dbdao.setUserProp(param, value,user.getId());
						}else{
							success= 2;
						}
						
					}else{
						value = StringEscapeUtils.escapeXml(value);
						value = value.replaceAll("(\r\n|\r|\n|\n\r)", "<br \\>");
						success = dbdao.setUserProp(param, value, user.getId());
						if(success == 1){
							if(param.equals("username")) user.setName(value);
							if(param.equals("location")) user.setLocation(value);
							request.getSession().setAttribute("user", user);
						}
						
					}	
				}else if(postType.equals("unfavorite")){
					int value = Integer.parseInt(request.getParameter("value"));
					DbDao dbdao = new DbDao();
					success = dbdao.unfavoriteUser(user.getId(), value);
				}else if(postType.equals("removeItem")){
					int itemId = Integer.parseInt(request.getParameter("value"));
					DbDao dbdao = new DbDao();
					success = dbdao.removeItem(itemId);
				}else if(postType.equals("itemDesc")){
					int itemId = Integer.parseInt(request.getParameter("itemId"));
					String desc = request.getParameter("itemDesc");
					desc = StringEscapeUtils.escapeXml(desc);
					desc = desc.replaceAll("(\r\n|\r|\n|\n\r)", "<br \\>");
					DbDao dbdao = new DbDao();
					success = dbdao.setItemProp("description", desc, itemId );
				}else if(postType.equals("reviewUser")){
					int swapId = Integer.parseInt(request.getParameter("swapId"));
					String title= request.getParameter("title");
					String reviewText = request.getParameter("reviewText");
					title = StringEscapeUtils.escapeXml(title);
					int rating = Integer.parseInt(request.getParameter("rating"));
					int otherUser = Integer.parseInt(request.getParameter("otherUser"));
					reviewText = StringEscapeUtils.escapeXml(reviewText);
					reviewText = reviewText.replaceAll("(\r\n|\r|\n|\n\r)", "<br \\>");
					DbDao db = new DbDao();
					success = db.reviewUser(swapId, user.getId(), title, reviewText, otherUser, rating);
				}else if(postType.equals("removeFaveSearch")){
					String searchTerm = request.getParameter("searchTerm");
					DbDao dao = new DbDao();
					success=dao.removeFaveSearch(user.getId(), searchTerm);
				}else if(postType.equals("addFaveSearch")){
					String searchTerm = request.getParameter("searchTerm");
					DbDao dao = new DbDao();
					success = dao.addFaveSearch(user.getId(), searchTerm);
				}
				response.setContentType("text/html");
				response.getWriter().print(success);
				response.getWriter().flush();
				response.getWriter().close();
		    	
		    }else if(request.getParameter("notajax").equals("message")){
				if(request.getSession().getAttribute("user") != null){
			    	DbDao dao = new DbDao();
		    		String content = request.getParameter("content");
		    		int conversationId = -1;
		    		if(request.getParameter("conversationId")!=null){
		    			conversationId = Integer.parseInt(request.getParameter("conversationId"));
		    		}
		    		if(request.getParameter("newSwap")!=null){
		    			String title = request.getParameter("title");
		    			title = StringEscapeUtils.escapeXml(title);
		    			int otherUser = Integer.parseInt(request.getParameter("otherUser"));
		    			int swapId = Integer.parseInt(request.getParameter("swapId"));
		    			conversationId = dao.addConversation( swapId, title);
		    			if(conversationId != -1){
			    			dao.addUserConversation(user.getId(), conversationId, "true");
			    			dao.addUserConversation(otherUser, conversationId, "false");
		    			}
		    		}else if(request.getParameter("newConv")!=null){
		    			String title = request.getParameter("title");
		    			title = StringEscapeUtils.escapeXml(title);
		    			int otherUser = Integer.parseInt(request.getParameter("otherUser"));
		    			conversationId = dao.addConversation( -1, title);
		    			if(conversationId != -1){
			    			dao.addUserConversation(user.getId(), conversationId, "true");
			    			dao.addUserConversation(otherUser, conversationId, "false");
		    			}
		    		}
		    		content = StringEscapeUtils.escapeXml(content);
					content = content.replaceAll("(\r\n|\r|\n|\n\r)", "<br \\>");
					dao.dirtyOtherUserMess(conversationId, user.getId());
		    		dao.addMessage(user.getId(), conversationId, content);
		    		MessageBean [] messages = dao.getMessages(conversationId);
					request.setAttribute("messages", messages);
					request.setAttribute("conversationId", conversationId);
					forward = MESSAGES_JSP;
				}else{
					if(user != null){
						DbDao dao = new DbDao();
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
				}
				RequestDispatcher view = request.getRequestDispatcher(forward);
				view.forward(request, response);
	    	}	
		}
	}
}
