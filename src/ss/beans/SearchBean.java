package ss.beans;

import javax.servlet.http.HttpServletRequest;

import ss.beans.ResultObject;
import ss.dao.DbDao;
public class SearchBean implements java.io.Serializable{

	private static final long serialVersionUID = 1L;
	
	public final String SEARCH_USERS = "user";
	public final String SEARCH_ITEMS = "item";
	
	private String query = "";
	private String searchType = "";
	private int numPages = 0;
	private int indexPage = 0;
	private int pageNum = 0;
	boolean smallSet = false;
	ResultObject[] pageArray = new ResultObject[0];
	public int[] location = null; //Form [blockId, gran1, gran2, gran3]
	
	private ResultObject[] ros;

	public SearchBean(){
		//TODO: Figure out how to initialize and get IP address for location finding.
		//autoSetLocation();
	}
	
	public ResultObject[] getItems(int pageNum, String searchType, String query, int userId, String category) {
		return getItems(pageNum, searchType, query, userId, category, 0);
	}
	
	public ResultObject[] getItems(int pageNum, String searchType, String query, int userId, String category, int radius) {
		this.pageNum = pageNum;
		radius = -1;
		System.out.println(pageNum + ":" + searchType + ":" + query);
		if(!query.equals(this.query) || !searchType.equals(this.searchType)){
			numPages = 0;
			this.indexPage = 0;
			this.searchType = searchType;
			this.query = query;
			//TODO: Check limit on first query, may be returning all.
			callDao(query, searchType, indexPage, userId, category, radius);
		}else if(pageNum!=this.indexPage){
			if(pageNum < this.indexPage) {
				callDao(query, searchType, indexPage-5, userId, category, radius);
				this.indexPage = pageNum;
			}
			if(pageNum > this.indexPage+4) {
				callDao(query, searchType, indexPage+5, userId, category, radius);
				this.indexPage = pageNum;
			}
		}
		
		if(ros!= null){
			pageArray = new ResultObject[10];
			if(ros.length < (pageNum - indexPage + 1) * 10){
				int shortPageLength = ros.length %10;
				pageArray = new ResultObject[shortPageLength];
				System.arraycopy(ros, ((pageNum - indexPage) *10), pageArray, 0, shortPageLength);
			}else{
				System.arraycopy(ros, ((pageNum - indexPage) *10), pageArray, 0, 10);
			}
			
		}
		return pageArray;
	}
	
	public int getNumPages(){
		return this.numPages;
	}
	
	public int getIndexPage(){
		return this.indexPage;
	}
	
	//TODO: Condition on checkNum allows for full query on initial search. Possible to limit final set? Important?
	private void callDao(String query, String searchType, int index, int userId, String category, int radius){
		DbDao db = new DbDao();
		ros = null;
		ros=db.search(query, searchType, index, userId, category, radius, location);
		if(ros != null){
			if(this.indexPage == this.pageNum){
				numPages = ros.length%10==0? ros.length/10: (ros.length/10) +1;
				/**ResultObject[] tempIndexSetArray = null;
				if(ros.length<50){
					tempIndexSetArray = new ResultObject[ros.length];
					System.arraycopy(ros,index*10, tempIndexSetArray, 0, ros.length);
				}else{
					tempIndexSetArray= new ResultObject[50];
					System.arraycopy(ros,index*10, tempIndexSetArray, 0, 50);
				}
				ros = tempIndexSetArray;**/	
			}
			if(ros.length < 50){
				smallSet = true;
			}else{
				smallSet = false;
			}
		}
	}
	
	public void autoSetLocation(HttpServletRequest request){
		DbDao db = new DbDao();
		System.out.println("RemAddr: " + request.getRemoteAddr());
		System.out.println("RemHost: " + request.getRemoteHost() );
		String ipAddress = request.getRemoteAddr();
		location = null;//db.getLocationByIp("24.68.70.242");
		if (location == null){
			int [] tempLoc = {-1,-1,-1,-1};
			location = tempLoc;
		}
	}
	
	public void manualSetLocation(HttpServletRequest request){
		
	}
	
	public int[] getLocation(){
		return location;
	}
}
