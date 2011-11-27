package ss.utilities;

import java.io.File;
import java.io.IOException;
import java.util.Calendar;
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

import ss.beans.Item;
import ss.beans.UserBean;
import ss.dao.DbDao;


/**
 * Servlet implementation class FileUploadServlet
 */
public class FileUploadServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public FileUploadServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		RequestDispatcher view = request.getRequestDispatcher("/User");
		view.forward(request, response);	
	}

	/**
	 * This is some of the worst code I've ever written. And it feels good to admit it.
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		ServletContext context = getServletContext();
		RequestContext reqContext = new ServletRequestContext(request);
	    boolean isMultipart = FileUploadBase.isMultipartContent(reqContext);
	    response.setContentType("text/html");
	    UserBean user = (UserBean)request.getSession().getAttribute("user");
	    String uploadType = "";
	    String itemId = "";
	    FileItem imgFile = null;

    	if(isMultipart){
	    	FileItemFactory factory = new DiskFileItemFactory();
	        ServletFileUpload upload = new ServletFileUpload(factory);
			try{
				List reqData = upload.parseRequest(request);
				Iterator reqIt = reqData.iterator();
				while(reqIt.hasNext()){
					FileItem fi = (FileItem)reqIt.next();
					
					if(fi.isFormField()){
						if(fi.getFieldName().equals("uploadType")) uploadType= fi.getString();
						if(fi.getFieldName().equals("itemId")) itemId= fi.getString();
					}
					if(!fi.isFormField()){
						if(fi.getName()!=null){
							if(!fi.getName().equals("")){
								imgFile = fi;
							}
						}
					}
				}
				Calendar now = Calendar.getInstance();
				DbDao db = new DbDao();
				String imageName = "";
				if(imgFile != null){
					imageName = now.getTimeInMillis() + user.getName() + imgFile.getName();
				}
				if(uploadType.equals("user")){
					File rootDir = new File(context.getRealPath("/img/user")) ; 
					if(db.setUserProp("imgName", imageName, user.getId()) == 1){
						File saveLoc = new File(rootDir, imageName);
						imgFile.write(saveLoc);
						if(user.getImg() != null){
							if(!user.getImg().equals("")){
								new File(rootDir, user.getImg()).delete();
							}
						}
						user.setImg(imageName);
						request.getSession().setAttribute("user", user);
						response.getWriter().print(imageName);
						response.getWriter().flush();
						response.getWriter().close();
					}	
				}else if(uploadType.equals("item")){
					File rootDir = new File(context.getRealPath("/img/item")) ; 
					if(!itemId.equals("")){
						Item oldItem = db.getItem(itemId);
						if(oldItem != null){
							if(db.setItemProp("imgName", imageName, Integer.parseInt(itemId)) == 1){
								File saveLoc = new File(rootDir, imageName);
								imgFile.write(saveLoc);
								if(oldItem.getImg() != null){
									if(!oldItem.getImg().equals("")){
										new File(rootDir, oldItem.getImg()).delete();
									}
								}
								response.getWriter().print(imageName);
								response.getWriter().flush();
								response.getWriter().close();
							}	
						}
					}
				}
				
			}catch(Exception e){
				System.out.println("Error during file upload");
				e.printStackTrace();
			}
	    }
	}
}
