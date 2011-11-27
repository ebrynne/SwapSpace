package ss.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

import ss.connection.ConnectionManager;
import ss.utilities.BCrypt;
import ss.beans.ConversationBean;
import ss.beans.MessageBean;
import ss.beans.Note;
import ss.beans.ResultObject;
import ss.beans.Review;
import ss.beans.StaticResources;
import ss.beans.Swap;
import ss.beans.UserBean;
import ss.beans.Item;


public class DbDao {
	public final String cancel = "cancel";
	public final String accept = "accept";
	public final String wait = "wait";
	public final String counter = "counter";
	public final String offer= "offer";
	public final String review= "review";
	
	/*
	 * 
	 * 
	 * Here are any and all test location searches.
	 * 
	 *
	 */
	
	/**
	 * Notes on performance and test choices:
	 * MY_SEARCH_JOIN vs WHERE: Same performance on postgresql
	 * MY_SEARCH_WITH_SUBBLOCK: Slow on POST
	 * MY_SEARCH_WITH: Same performance on POST
	 */
	
	//private final String MY_SEARCH_JOIN = "SELECT * from ? inner join (SELECT case blockRelPos WHEN 1 THEN (?+subBlockPosId) WHEN 2 THEN(?+subBlockPosId)WHEN 3 THEN(?+subBlockPosId) WHEN 4 THEN (?+subBlockPosId) WHEN 5 THEN (?+subBlockPosId) WHEN 6 THEN (?+subBlockPosId) WHEN 7 THEN (?+subBlockPosId) WHEN 8 THEN (?+subBlockPosId) WHEN 9 THEN (?+subBlockPosId) END AS realId FROM gran3 WHERE blockId=? AND radius<=50) as temp on  (testlocations2.blockg3=temp.realId);";
	//private final String MY_SEARCH_WHERE = "SELECT * from ?, (SELECT subBlockPosId, case blockRelPos WHEN 1 THEN (?+subBlockPosId) WHEN 2 THEN ? WHEN 3 THEN (?+subBlockPosId) WHEN 4 THEN (?+subBlockPosId) WHEN 5 THEN (?+subBlockPosId) WHEN 6 THEN (?+subBlockPosId) WHEN 7 THEN (?+subBlockPosId) WHEN 8 THEN (?+subBlockPosId) WHEN 9 THEN (?+subBlockPosId) END AS realId FROM gran3 WHERE blockId=? AND radius<=50) as temp where testlocations2.blockg3=temp.realId;";
	//private final String MY_SEARCH_WITH_SUBBLOCK = "WITH temp as (SELECT subBlockPosId, blockId, blockRelPos, radius, case blockRelPos WHEN 1 THEN (1000+subBlockPosId) WHEN 2 THEN (2000+subBlockPosId) WHEN 3 THEN (3000 + subBlockPosId) WHEN 4 THEN (4000+subBlockPosId) WHEN 5 THEN (5000+subBlockPosId) WHEN 6 THEN (6000+subBlockPosId) WHEN 7 THEN (7000+subBlockPosId) WHEN 8 THEN (8000+subBlockPosId) WHEN 9 THEN (9000+subBlockPosId) END AS realId FROM ssdb.gran3 WHERE blockId=5 AND radius<50) SELECT locid from ssdb.testlocations2, temp WHERE blockg3=realId and testlocations2.gran3=temp.subblockposid;";
	//private final String MY_SEARCH_WITH = "WITH temp as (SELECT subBlockPosId, blockId, blockRelPos, radius, case blockRelPos WHEN 1 THEN (1000+subBlockPosId) WHEN 2 THEN (2000+subBlockPosId) WHEN 3 THEN (3000 + subBlockPosId) WHEN 4 THEN (4000+subBlockPosId) WHEN 5 THEN (5000+subBlockPosId) WHEN 6 THEN (6000+subBlockPosId) WHEN 7 THEN (7000+subBlockPosId) WHEN 8 THEN (8000+subBlockPosId) WHEN 9 THEN (9000+subBlockPosId) END AS realId FROM ssdb.gran3 WHERE blockId=5 AND radius<50) SELECT locid from ssdb.testlocations2, temp WHERE blockg3=realId;";
	//[table, 1000*{realBlocks 1-9}, subBlock, radius, 1000*{realBlocks 1-9}]
	private final String MY_SEARCH_WHERE_LIMIT_9 = "SELECT locid from ssdb.testlocations2, (SELECT case blockRelPos WHEN 1 THEN (?+subBlockPosId) WHEN 2 THEN (?+subBlockPosId) WHEN 3 THEN (? + subBlockPosId) WHEN 4 THEN (?+subBlockPosId) WHEN 5 THEN (?+subBlockPosId) WHEN 6 THEN (?+subBlockPosId) WHEN 7 THEN (?+subBlockPosId) WHEN 8 THEN (?+subBlockPosId) WHEN 9 THEN (?+subBlockPosId) END AS realId FROM ssdb.gran3 WHERE blockId=? AND radius<?) as temp where blockg3=realId;";
	private final String TRIG_SEARCH = "SELECT locid FROM ssdb.testlocations2 where SQRT(POW(111 * (latitude - ?), 2) + POW( 111 * (longitude - ?) * COS( latitude / 92.2 ) , 2 ) ) < ? and blockId in(?,?,?,?,?,?,?,?,?);";
	private final String CIRCLE_GEOM = "SELECT locid FROM ssdb.testlocations2 WHERE (6374 * acos(sin(latitude/57.2958) * sin(?/57.2958) + cos(latitude/57.2958) * cos(?/57.2958) *  cos(?/57.2958 -longitude/57.2958))) < ? and blockId in(?,?,?,?,?,?,?,?,?);";
	//[table, long, lat]
	private final String ST_DWITHIN_SHEREOID =  "SELECT locid FROM ssdb.testlocations2 WHERE st_DWithin( pongeog, Geography(ST_SetSRID(ST_MakePoint(?, ?),4326)), ?);";
	//[table, long, lat]
	private final String ST_DWITHIN_SHERE =  "SELECT locid FROM ssdb.testlocations2 WHERE st_DWithin( pongeog, Geography(ST_SetSRID(ST_MakePoint(?, ?),4326)), ?, false);";
	//[table, minx, miny, maxx, maxy, pointlong, pointlat]
	private final String OVERLAP_AND_DISTANCE = "SELECT locid from ssdb.testlocations2 where pongeog && Geography(Cast('BOX(? ?, ? ?)' as Box2d)) and st_distance(pongeog, ST_GeogFromText('POINT(? ?)')) < 50000;";

	
	/*
	 * 
	 * 
	 * Here endeth the testing.
	 * 
	 * 
	 */
	
	private final String LOCATION_SEARCH_SMALL = "in (select userId from users, (SELECT subBlockPosId, case blockRelPos WHEN 1 THEN ? WHEN 2 THEN ? WHEN 3 THEN ? WHEN 4 THEN ? WHEN 5 THEN ? WHEN 6 THEN ? WHEN 7 THEN ? WHEN 8 THEN ? WHEN 9 THEN ? END AS realId FROM # WHERE blockId=? AND radius<=?) AS realPos WHERE users.blockId=realId AND users.subBlockId=subBlockPosId)";
	private final String LOCATION_SEARCH_BROAD = "in (select userId from users, (SELECT subBlockPosId, case blockRelPos WHEN 1 THEN ? WHEN 2 THEN ? WHEN 3 THEN ? WHEN 4 THEN ? WHEN 5 THEN ? WHEN 6 THEN ? WHEN 7 THEN ? WHEN 8 THEN ? WHEN 9 THEN ? WHEN 10 THEN ? WHEN 11 THEN ? WHEN 13 THEN ? WHEN 14 THEN ? WHEN 15 THEN ? WHEN 16 THEN ? WHEN 17 THEN ? WHEN 18 THEN ? WHEN 19 THEN ? WHEN 20 THEN ? WHEN 21 THEN ? WHEN 22 THEN ? WHEN 23 THEN ? WHEN 24 THEN ? WHEN 25 THEN ? END AS realId FROM subBlocks WHERE blockId=? AND radius<=?) AS realPos WHERE users.blockId=realId AND users.subBlockId=subBlockPosId)";
	
	private final String ADD_ITEM = "INSERT INTO items (ownerId, name, category, description, imgName) value (?, ?, ?, ?, ?)";
	private final String ADD_ITEM_TO_SWAP = "INSERT INTO swapItems values (?,?)";
	private final String ADD_USER_TO_SWAP = "INSERT INTO userSwaps (userId, swapId, otherUser, dirty, status) values (?, ?, ?, ?, ?)";
	private final String ADD_CONVERSATION = "INSERT INTO conversations (swapId, title, createdAt) values (?, ?, NOW())";
	private final String ADD_USER_CONVERSATION = "INSERT INTO userConversations (userId, conversationId, dirty) values (?, ?, ?)";
	private final String ADD_MESSAGE = "INSERT INTO messages (ownerId, conversationId, content) values (?,?,?)";
	private final String ADD_FAVE_SEARCH = "INSERT INTO faveSearches values (?,?)";	
	
	private final String GET_BLOCK_BY_LAT_LONG = "select blockId, latTL, longTL from blocks where latTL=(select min(latTL) from blocks where latTL > ?) and latBR=(select max(latBR) from blocks where latBR < ?) and longTL< ? and longBR > ?";	
	private final String GET_LAT_LONG_BY_IP = "SELECT latitude, longitude FROM ipLocations WHERE ipStart = (SELECT MAX(ipStart) FROM ipLocations WHERE ipStart < ?) AND ipEnd = (select MIN(ipEnd) FROM ipLocations WHERE ipEnd > ?)";
	private final String GET_NEWS = "SELECT news from siteNews ORDER BY createdAt LIMIT 1";
	private final String GET_NOTES = "SELECT authorId, username, content FROM notes, users WHERE notes.userId=? AND notes.authorId=users.userId order by notes.createdAt DESC LIMIT 100";
	private final String GET_USER = "SELECT username, guid, email, userId, imgName, active, password, location, description, lookingFor, rating FROM users WHERE email=?";
	private final String GET_USER_BY_ID = "SELECT username, email, guid, userId, imgName, active, location, description, lookingFor, rating FROM users WHERE userId=?";
	private final String GET_ITEM_BY_ID = "SELECT * FROM items WHERE itemId=?";
	private final String GET_ITEMS_FOR_USER = "SELECT * from items WHERE ownerId=? AND items.status!='swapped' order by createdAt DESC";
	private final String GET_SWAPS_ITEMS_FOR_USERS = "SELECT swaps.finalized, swaps.swapId, userSwaps.dirty, users.username, users.userId, userSwaps.lastModified, userSwaps.status, items.name, items.description, items.imgName, items.category, items.status, items.itemId, items.ownerId FROM users, ((userSwaps inner join swaps on userSwaps.swapId = swaps.swapId) inner join swapItems on swaps.swapId = swapItems.swapId) inner join items on swapItems.itemId = items.itemId WHERE userSwaps.userId = ? AND users.userId=userSwaps.otherUser order by lastModified desc;";
	private final String GET_FAVE_USERS= "SELECT username, users.userId, imgName, active, location, rating from users INNER JOIN faveUsers ON users.userId=faveUsers.faveId WHERE faveUsers.userId=?";
	private final String GET_NUM_DIRTY_SWAPS = "SELECT count(swapId) as num from userSwaps WHERE userId=? AND dirty='true'";
	private final String GET_NUM_DIRTY_MESS = "SELECT count(conversationId) as num from userConversations where userId=? and dirty='true'";
	private final String GET_OTHER_SWAP_USER = "select userSwaps.userId from swaps INNER JOIN userSwaps on swaps.swapId = userSwaps.swapId where swaps.swapId=? AND userId!=?";
	private final String GET_NUM_REVIEWS = "SELECT count(reviewId) as numReviews FROM reviews WHERE userId=?";
	private final String GET_REVIEWS = "SELECT reviewId, title, content, reviews.reviewerId, users.username, reviews.rating, reviews.createdAt FROM reviews, users WHERE reviews.userId=? AND reviews.reviewerId=users.userId LIMIT ?, ?";
	private final String GET_CONVERSATIONS = "SELECT title, type, conversations.createdAt, userConversations.conversationId, lastmodified, dirty, username FROM conversations, userConversations, users WHERE userConversations.conversationId=conversations.conversationId AND userConversations.userId=users.userId AND users.userId!=? AND conversations.conversationId IN (SELECT conversationId FROM userConversations WHERE userId=? ) ORDER BY lastModified DESC;";
	private final String GET_MESSAGES = "SELECT content, messages.createdAt, username, conversationId, messages.ownerId FROM messages, users WHERE users.userId=messages.ownerId AND conversationId=? ORDER BY messages.createdAt DESC";
	private final String GET_CONVERSATION_ID_BY_SWAP = "Select conversationId from conversations WHERE swapId =?";
	private final String GET_FRIENDS = "SELECT username, users.userId FROM users, faveUsers WHERE faveUsers.userId=users.userId AND users.userId IN (SELECT faveId FROM faveUsers WHERE userId=?) AND faveId=?";
	private final String GET_FAVE_SEARCHES = "SELECT searchTerm FROM faveSearches WHERE userId=?";
	private final String GET_FAVE_SEARCH_ITEMS = "SELECT MATCH(name, description) AGAINST (? IN NATURAL LANGUAGE MODE) as relevance, createdAt, description, itemId, imgName, ownerId, name FROM items ORDER BY relevance DESC LIMIT 2";
	private final String GET_FAVE_USER_ITEMS = "SELECT description, createdAt, name, itemId, ownerId, imgName FROM items WHERE ownerId=? ORDER BY createdAt DESC LIMIT 2";
	private final String GET_USERID_BY_GUID = "SELECT userId FROM users WHERE guid=?";
	
	private final String VALIDATE_USER_PROPERTY_P1 = "SELECT username from users WHERE ";
	private final String VALIDATE_USER_PROPERTY_P2 = "=?";
	
	private final String SET_USER_PROP = "UPDATE users SET #=? where userId=?";
	private final String SET_ITEM_PROP = "UPDATE items SET #=? WHERE itemId=?";
	private final String SET_ITEMS_SWAPPED = "UPDATE items SET status='swapped' WHERE itemId IN (SELECT itemId from swapItems WHERE swapId=?)";
	private final String SET_OTHER_SWAPS_CANCEL = "UPDATE userSwaps SET status='cancel' WHERE swapId IN(SELECT swapId FROM swapItems WHERE itemId IN (SELECT itemId from swapItems WHERE swapId =?)) AND swapId !=?";
	
	private final String SEARCH_CONVERSATIONS_ALL = "SELECT ((cscore + nscore + tscore)/3) as ascore, conversationId, dirty, title, username, lastModified FROM (select MATCH(users.username) AGAINST(? IN NATURAL LANGUAGE MODE) as nscore, MATCH(conversations.title) against(? IN NATURAL LANGUAGE MODE) as tscore, MATCH(messages.content) against(? IN NATURAL LANGUAGE MODE) as cscore, conversations.title, users.username, userConversations.dirty, conversations.lastModified, conversations.conversationId FROM userConversations, conversations, messages, users WHERE userConversations.conversationId=conversations.conversationId AND userConversations.userId=users.userId AND users.userId!=? AND conversations.conversationId IN (SELECT conversationId from userConversations WHERE userId=?) AND conversations.conversationId=messages.conversationId  ORDER BY ((cscore + tscore+nscore)/3) DESC) as sortedSearch WHERE (cscore + nscore+tscore)!=0;";
	//TODO: Check limit on first query, may be returning all.
	//private final String SEARCH_USERS_ALL = "SELECT MATCH(username, lookingFor, description) AGAINST(? IN NATURAL LANGUAGE MODE) as relevance, username, userId, location, imgName, rating FROM users WHERE MATCH(username, description, lookingFor) AGAINST(? IN NATURAL LANGUAGE MODE) AND userId !=?";
	private final String SEARCH_USERS_LIM = "SELECT MATCH(username, lookingFor, description) AGAINST(? IN NATURAL LANGUAGE MODE) as relevance, username, userId, location, imgName, rating FROM users WHERE userId !=? AND MATCH(username, description, lookingFor) AGAINST(? IN NATURAL LANGUAGE MODE) LIMIT ?,?";
	//private final String SEARCH_ITEMS_ALL = "SELECT MATCH(name, description) AGAINST(? IN NATURAL LANGUAGE MODE) as relevance, name, itemId, ownerId, description, category, imgName FROM items WHERE MATCH(name, description) AGAINST(? IN NATURAL LANGUAGE MODE) AND ownerId !=?";
	private final String SEARCH_ITEMS_LIM = "SELECT MATCH(name, description) AGAINST(? IN NATURAL LANGUAGE MODE) as relevance, name, itemId, ownerId, description, category, imgName FROM items WHERE ownerId !=? AND MATCH(name, description) AGAINST(? IN NATURAL LANGUAGE MODE) LIMIT ?,?";
	
	private final String REMOVE_FAVE_SEARCH = "DELETE FROM faveSearches WHERE userId=? AND searchTerm=?";
	private final String REMOVE_ITEM = "DELETE FROM items WHERE itemId=?";
	private final String REMOVE_ITEMS_FROM_SWAP = "DELETE FROM swapItems WHERE swapId=?";
	
	private final String VALID_LOCATION = "SELECT location FROM locations WHERE location=?";
	private final String INSERT_NOTE = "INSERT INTO NOTES (authorId, userId, content) values (?, ?, ?)";
	private final String REVIEW_USER = "INSERT INTO REVIEWS (title, content, userId, swapId, reviewerId, rating) values (?, ?, ?, ?, ?, ?)";
	private final String CREATE_SWAP = "INSERT INTO swaps values ()";
	private final String CHECK_PASS = "SELECT username FROM users WHERE password=? AND userId=?";
	private final String UNFAVORITE_USER = "DELETE FROM faveUsers WHERE userId=? AND faveId=?";
	private final String FAVORITE_USER = "INSERT INTO faveUsers VALUES (?,?)";
	private final String IS_FAVORITE_USER = "SELECT * FROM faveUsers WHERE userId=? AND faveId=?";
	private final String REGISTER_USER = "INSERT INTO users (username, password, email, location, rating) values ( ?, ?, ?, ?, ?)";
	private final String CLEAN_SWAP = "UPDATE userSwaps SET dirty='false' WHERE swapId=? AND userId=?";
	private final String CLEAN_CONVERSATION = "UPDATE userConversations SET dirty='false' WHERE conversationId=? and userId=?";
	private final String DIRTY_SWAP = "UPDATE userSwaps SET dirty='true' WHERE swapId=? AND userId=?";
	private final String DIRTY_CONVERSATION_OTHER_USER = "UPDATE userConversations SET dirty='true' WHERE conversationId=? and userId!=?";
	private final String CANCEL_SWAP= "UPDATE userSwaps SET status='cancel', dirty='true' WHERE swapId=?";
	private final String ACCEPT_SWAP= "UPDATE userSwaps SET status='accept', dirty='true' WHERE swapId=?";
	private final String UPDATE_SWAP_STATUS= "UPDATE userSwaps SET status=? WHERE swapId=? AND userId=?";
	private final String NEEDS_REVIEW = "SELECT userSwaps.swapId FROM userSwaps, swaps WHERE userSwaps.swapId=swaps.swapId AND userSwaps.status='accept' AND userSwaps.swapId=? AND userSwaps.userId=?";
	private final String IS_NEW_CONVERSATION = "SELECT conversationId FROM conversations WHERE swapId=?";
		
	//TODO: Break up? Nope! 
	Connection conn;
	ConnectionManager cm;
	
	public DbDao(Connection conn, ConnectionManager cm){
		this.conn = conn;
		this.cm = cm;
	}
	
	public DbDao (){
		this.cm = new ConnectionManager();
		conn = cm.getConnection();
	}
	
	public DbDao (String type){
		this.cm = new ConnectionManager();
		conn = cm.getConnection(type);
	}
	
	public UserBean login(String email, String pass){
		UserBean usr = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		 
		 try{
			 ps = conn.prepareStatement(GET_USER);
			 ps.setString(1, email);
			 rs = ps.executeQuery();
			 if(rs.next()){
				 if(BCrypt.checkpw(pass, rs.getString("password"))){
					 usr = new UserBean();
					 usr.setId(rs.getInt("userId"));
					 usr.setEmail(rs.getString("email"));
					 if(rs.getString("location")!=null)
						usr.setLocation(rs.getString("location"));
					 usr.setActive(rs.getString("active"));
					 usr.setName(rs.getString("username"));
					 usr.setImg(rs.getString("imgName"));
					 usr.setGuid(rs.getString("guid"));
					 if(rs.getString("description")!=null)
					 	usr.setDescription(rs.getString("description"));
					 if(rs.getString("lookingFor") != null)
						usr.setLookingFor(rs.getString("lookingFor"));
				 }
			 }
		 }catch(SQLException e){
			 System.out.println("Query failure in getting user");
			 e.printStackTrace();
		 }
		 
		 cm.closeResultSet(rs);
		 cm.closePreparedStatement(ps);
		 
		return usr;
	}
	
	public int getUserIdByGuid(String guid){
		int userId = -1;
		PreparedStatement ps = null;
		ResultSet rs = null;
		 
		 try{
			 ps = conn.prepareStatement(GET_USERID_BY_GUID);
			 ps.setString(1, guid);
			 rs = ps.executeQuery();
			 if(rs.next()){
				 userId = rs.getInt("userId");
			 }
		 }catch(SQLException e){
			 System.out.println("Query failure in getting userId by Guid");
			 e.printStackTrace();
		 }
		 
		 return userId;
	}
	
	public UserBean getUser(int userId){
		UserBean usr = null;
		 PreparedStatement ps = null;
		 ResultSet rs = null;
		 
		 try{
			 ps = conn.prepareStatement(GET_USER_BY_ID);
			 ps.setInt(1, userId);
			 rs = ps.executeQuery();
			 if(rs.next()){
				 usr = new UserBean();
				 usr.setId(rs.getInt("userId"));
				 usr.setEmail(rs.getString("email"));
				 if(rs.getString("location")!=null)
					usr.setLocation(rs.getString("location"));
				 usr.setActive(rs.getString("active"));
				 usr.setName(rs.getString("username"));
				 usr.setImg(rs.getString("imgName"));
				 usr.setGuid(rs.getString("guid"));
				 if(rs.getString("description")!=null)
				 	usr.setDescription(rs.getString("description"));
				 if(rs.getString("lookingFor") != null)
					usr.setLookingFor(rs.getString("lookingFor"));
				 usr.setRating(rs.getDouble("rating"));
			 }
		 }catch(SQLException e){
			 System.out.println("Query failure in getting user");
			 e.printStackTrace();
		 }
		 
		 cm.closeResultSet(rs);
		 cm.closePreparedStatement(ps);
		 
		return usr;
	}
	
	public String validateUserData(String prop, String val){
		System.out.println("SADF");
		PreparedStatement ps = null;
		ResultSet rs = null;
		String validateUserProperty = VALIDATE_USER_PROPERTY_P1 + prop + VALIDATE_USER_PROPERTY_P2;
		try{
			ps = conn.prepareStatement(validateUserProperty);
			ps.setString(1, val);
			rs = ps.executeQuery();
			if(rs.next()){
				return "2";
			}
		}catch(SQLException e){
			System.out.println("Query failure in validation");
			e.printStackTrace();
			return "3";
		}
		
		return "1";
	}
	
	public int reviewUser(int swapId, int userId, String title, String reviewText, int reviewedId, int rating){
		int success = 0;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(REVIEW_USER);
			ps.setString(1, title);
			ps.setString(2, reviewText);
			ps.setInt(3, reviewedId);
			ps.setInt(4, swapId);
			ps.setInt(5, userId);
			ps.setInt(6, rating);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Query failure in validation");
			e.printStackTrace();
			success = 2;
		}
		
		return success;
	}
	
	public boolean registerUser (String username, String password, String email, String location){
		PreparedStatement ps = null;
		try{
			String salt = BCrypt.gensalt();
			ps = conn.prepareStatement(REGISTER_USER);
			ps.setString(1, username);
			ps.setString(2, BCrypt.hashpw(password,salt));
			ps.setString(3, email);
			ps.setString(4, location);
			ps.setInt(5, -1);
			ps.execute();
		}catch(SQLException e){
			System.out.println("Query failure in registration");
			e.printStackTrace();
			return false;
		}
		
		return true;
	}
	
	public boolean checkPass(String pass, int userId){
		boolean rightPass = false;
		PreparedStatement ps = null;
		ResultSet rs  = null;
		try{
			ps = conn.prepareStatement(CHECK_PASS);
			ps.setString(1, pass);
			ps.setInt(2, userId);
			rs = ps.executeQuery();
			if(rs.next()){
				rightPass = true;
			}
		}catch(SQLException e){
			System.out.println("Query failure in password validation");
			e.printStackTrace();
		}
		
		return rightPass;
	}
	
	//TODO: CHANGE AVAILABLE/SWAP STATUS
	public Item[] getUserItems(int userId){
		PreparedStatement ps = null;
		ResultSet rs = null;
		Item[] itemArray = new Item[0];
		ArrayList<Item> items =new ArrayList<Item>();

		try{
			ps = conn.prepareStatement(GET_ITEMS_FOR_USER);
			ps.setInt(1, userId);
			rs = ps.executeQuery();
			while(rs.next()){
				Item newItem = new Item();
				newItem = new Item();
				newItem.setOwnerId(rs.getInt("ownerId"));
				newItem.setId(rs.getInt("itemId"));
				newItem.setName(rs.getString("name"));
				newItem.setDescription(rs.getString("description"));
				newItem.setCatagory(rs.getString("category"));
				if(rs.getString("imgName") != null){
					newItem.setImg(rs.getString("imgName"));
				}
				items.add(newItem);
			}
		}catch(SQLException e){
			System.out.println("Query failure in getUserItems");
			e.printStackTrace();
			return null;
		}
		itemArray = new Item[items.size()];
		return items.toArray(itemArray);
	}
	
	public Item getItem(String itemId){
		Item item = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps = conn.prepareStatement(GET_ITEM_BY_ID);
			ps.setInt(1, Integer.parseInt(itemId));
			rs = ps.executeQuery();
			while(rs.next()){
				item = new Item();
				item.setOwnerId(rs.getInt("ownerId"));
				item.setId(rs.getInt("itemId"));
				item.setName(rs.getString("name"));
				item.setDescription(rs.getString("description"));
				item.setCatagory(rs.getString("category"));
				if(rs.getString("imgName") != null){
					item.setImg(rs.getString("imgName"));
				}
			}
		}catch(SQLException e){
			System.out.println("Query failure on getItem");
			e.printStackTrace();
			return null;
		}
		return item;
		
	}
	
	public UserBean[] getFaveUsers(int userId){
		PreparedStatement ps = null;
		ResultSet rs = null;
		UserBean[] userArray = null;
		ArrayList<UserBean> users =new ArrayList<UserBean>();
		try{
			ps = conn.prepareStatement(GET_FAVE_USERS);
			ps.setInt(1, userId);
			rs = ps.executeQuery();
			while(rs.next()){
				UserBean user = new UserBean(rs.getString("username"), rs.getInt("userId"), rs.getDouble("rating"));
				user.setActive(rs.getString("active"));
				if(rs.getString("imgName") != null){
					user.setImg(rs.getString("imgName"));
				}
				if(rs.getString("location") != null){
					user.setImg(rs.getString("location"));
				}
				users.add(user);
			}
		}catch(SQLException e){
			System.out.println("Query failure on favorite user query");
			e.printStackTrace();
			return null;
		}
		userArray = new UserBean[users.size()];
		for(int i = 0; i<users.size(); i++){
			userArray[i] = users.get(i);
		}
		return userArray;
	}

	public int setUserProp(String param, String value, int id) {
		PreparedStatement ps = null;
		int result = 2;
		String query = SET_USER_PROP;
		query = query.replace("#", param);
		System.out.println(query + value + id);
		try{
			ps=conn.prepareStatement(query);
			ps.setString(1, value);
			ps.setInt(2, id);
			ps.execute();
			result = 1;
		}catch(SQLException e){
			System.out.println("Error changing user property");
			e.printStackTrace();
		}
		return result;
	}
	
	public int unfavoriteUser(int userId, int faveId){
		int result  = 2;
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement(UNFAVORITE_USER);
			ps.setInt(1, userId);
			ps.setInt(2, faveId);
			ps.execute();
			result = 1;
		}catch(SQLException e){
			System.out.println("Error changing user property");
			e.printStackTrace();
		}
		return result;
	}	
	
	public int favoriteUser(int userId, int faveId){
		int result  = 2;
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement(FAVORITE_USER);
			ps.setInt(1, userId);
			ps.setInt(2, faveId);
			ps.execute();
			result = 1;
		}catch(SQLException e){
			System.out.println("Error changing user property");
			e.printStackTrace();
		}
		return result;
	}
	
	public int addItem(int userId, String imgName, String itemName, String itemDesc, String itemCate){
		int success = 2;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(ADD_ITEM);
			ps.setInt(1, userId);
			ps.setString(2, itemName);
			ps.setString(3, itemCate);
			ps.setString(4, itemDesc);
			ps.setString(5, imgName);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Query failure in registration");
			e.printStackTrace();
		}
		
		return success;
	}
	
	public int setItemProp(String prop, String val, int itemId){
		int success = 2;
		PreparedStatement ps = null;
		String query = SET_ITEM_PROP;
		query = query.replace("#", prop);
		System.out.println(query + val + itemId);
		try{
			ps=conn.prepareStatement(query);
			ps.setString(1, val);
			ps.setInt(2, itemId);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Error changing user property");
			e.printStackTrace();
		}
		return success;
	}
	
	public int removeItem(int itemId){
		int result  = 2;
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement(REMOVE_ITEM);
			ps.setInt(1, itemId);
			ps.execute();
			result = 1;
		}catch(SQLException e){
			System.out.println("Error changing user property");
			e.printStackTrace();
		}
		return result;	
	}
	
	public ResultObject[] search(String search, String searchType, int index, int userId, String category, int range, int [] location){
		PreparedStatement ps = null;
		ResultSet rs = null;
		String query = "";
		StaticResources sr = StaticResources.getStaticResources();
		TreeMap<Double, Integer> blockRows = sr.getblockMap();
		String granularity = "";
		String locationSearch = "";
		int subBlock = 0;
		if(1 <= range && range <= 50){
			granularity = "gran3";
			subBlock = location[3];
			locationSearch = LOCATION_SEARCH_SMALL;
		}else if(50 <= range && range <= 100){
			granularity = "gran2";
			subBlock = location[2];
			locationSearch = LOCATION_SEARCH_SMALL;
		}else if(1 <= range && range <= 200){
			granularity = "gran1";
			subBlock = location[1];
			locationSearch = LOCATION_SEARCH_BROAD;
		}
		
		//TODO: Improve finding adjacent blocks; Check edge cases (block iteration final and first rows).; 
		//NOTE: Look for last row.
		ArrayList<ResultObject> results = new ArrayList<ResultObject>();
		if(searchType.equals("user")) query = SEARCH_USERS_LIM;
		else if(searchType.equals("item")) query = SEARCH_ITEMS_LIM;
		Double nextLatRow = new Double(-1);
		if(range > 0 && range <201){
			locationSearch.replace("#".subSequence(0, 1), granularity.subSequence(0, granularity.length()));
			query += (searchType.equals("user") ? " AND userId " : " AND ownerId ") + locationSearch;
			//TODO:Fix that if it finishes loop due to being on the last row it bumps up a row.
			for(Map.Entry<Double, Integer> blockMap : blockRows.entrySet()){
				nextLatRow = blockMap.getKey();
				if (blockMap.getValue() > location[0]) break;
			}
		}
		System.out.println(query);
		try{
			ps=conn.prepareStatement(query);
			ps.setString(1, search);
			ps.setInt(2, userId);
			ps.setString(3, search);
			ps.setInt(4, index);
			ps.setInt(5, index+50);
			
			//TODO: UNFIXED EDGE CASE: On the first block of any row, the end blocks of the above row are returned as the blocks on the same row to the left;
			if(range > 0 && range <101){
				int horizontalOffset = location[0] - blockRows.lowerEntry(nextLatRow).getValue().intValue()-1;
				Double [] rowSet = {blockRows.lowerEntry(nextLatRow).getKey(),nextLatRow,blockRows.higherEntry(nextLatRow) == null ? new Double(-1): blockRows.higherEntry(nextLatRow).getKey()};
				for(int i = 0; i< 9; i++){
					ps.setInt(5+i+1, rowSet[i/3].compareTo(new Double(-1)) == 0 ? -1 : blockRows.get(rowSet[i/3]).intValue() + horizontalOffset + i%3);
				}
				ps.setInt(15, subBlock);
				ps.setInt(15, range);
			}else if(range >= 101 && range < 201){
				int horizontalOffset = location[0] - blockRows.lowerEntry(nextLatRow).getValue().intValue()-2;
				Double [] rowSet = {blockRows.lowerEntry(blockRows.lowerEntry(nextLatRow).getKey()) == null ? new Double(-1): blockRows.lowerEntry(blockRows.lowerEntry(nextLatRow).getKey()).getKey(), blockRows.lowerEntry(nextLatRow).getKey(),nextLatRow,blockRows.higherEntry(nextLatRow) == null ? new Double(-1): blockRows.higherEntry(nextLatRow).getKey(), nextLatRow,blockRows.higherEntry(nextLatRow) == null ? new Double(-1): blockRows.higherEntry(blockRows.higherEntry(nextLatRow).getKey()) == null ? new Double(-1):blockRows.higherEntry(blockRows.higherEntry(nextLatRow).getKey()).getKey()};
				for(int i = 0; i<25; i++){
					ps.setInt(5+i+1, blockRows.get(rowSet[i/5]).intValue() + horizontalOffset + i%5);
				}
				ps.setInt(31, subBlock);
				ps.setInt(32, range);
			}else{
				
			}
			rs = ps.executeQuery();
			while(rs.next()){
				if(searchType.equals("user")){
					UserBean user = new UserBean(rs.getString("username"), rs.getInt("userId"), rs.getDouble("rating"));
					if(rs.getString("imgName") != null){
						user.setImg(rs.getString("imgName"));
					}
					if(rs.getString("location") != null){
						user.setImg(rs.getString("location"));
					}
						results.add(user);
				}else if(searchType.equals("item")){
					Item item = new Item();
					item.setOwnerId(rs.getInt("ownerId"));
					item.setId(rs.getInt("itemId"));
					item.setName(rs.getString("name"));
					item.setDescription(rs.getString("description"));
					item.setCatagory(rs.getString("category"));
					if(rs.getString("imgName") != null){
						item.setImg(rs.getString("imgName"));
					}
					results.add(item);
				}
			}
		}catch(SQLException e){
			System.out.println("Search error. Whoops!");
			e.printStackTrace();
		}
		ResultObject[] roArray = new ResultObject[results.size()];
		for(int i = 0; i< results.size(); i++){
			roArray[i] = results.get(i);
		}
		
		return roArray;
	}

	public boolean isFavorite(int userId, int faveId) {
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps = conn.prepareStatement(IS_FAVORITE_USER);
			ps.setInt(1, userId);
			ps.setInt(2, faveId);
			rs = ps.executeQuery();
			if(rs.next()){
				return true;
			}
		}catch(SQLException e){
			System.out.println("Error checking favorite user");
			e.printStackTrace();
			return false;
		}
		return false;
	}
	
	public int createSwap(){
		PreparedStatement ps = null;
		ResultSet rs = null;
		int swapId = -1;
		try{
			ps = conn.prepareStatement(CREATE_SWAP, Statement.RETURN_GENERATED_KEYS);
			ps.executeUpdate();
			rs = ps.getGeneratedKeys();
			swapId = rs.next() ? rs.getInt(1) : -1;
		}catch(SQLException e){
			System.out.println("Error while creating swaps");
			e.printStackTrace();
			return swapId;
		}		
		return swapId;
	}
	
	public int addUserSwap(int userId, int otherId, int swapId, boolean isDirty){
		PreparedStatement ps = null;
		int success = 2;
		try{
			ps = conn.prepareStatement(ADD_USER_TO_SWAP);
			String dirty = "true";
			ps.setInt(1, userId);
			ps.setInt(2, swapId);
			ps.setInt(3, otherId);
			ps.setString(4, dirty);
			if(isDirty) ps.setString(5, "offer");
			else ps.setString(5, "wait");
			ps.execute();
			success  = 1;
		}catch(SQLException e){
			System.out.println("Error adding user swap");
			e.printStackTrace();
		}
		
		return success;
	}
	
	public int addItemToSwap(int itemId, int swapId){
		PreparedStatement ps = null;
		int success = 2;
		try{
			ps = conn.prepareStatement(ADD_ITEM_TO_SWAP);
			ps.setInt(1, itemId);
			ps.setInt(2, swapId);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Error adding item to swap");
			e.printStackTrace();
		}
		return success;
	}
	
	public Swap[] getSwapsItemsForUsers(int userId){
		PreparedStatement ps = null;
		ResultSet rs = null;
		ArrayList<Swap> swaps = new ArrayList<Swap>();
		try{
			ps = conn.prepareStatement(GET_SWAPS_ITEMS_FOR_USERS);
			ps.setInt(1, userId);
			rs = ps.executeQuery();
			ArrayList<Item> swapItems = new ArrayList<Item>();
			while (rs.next()){
				Swap swap = new Swap();
				Item item = new Item();
				item.setOwnerId(rs.getInt("ownerId"));
				item.setId(rs.getInt("itemId"));
				item.setName(rs.getString("name"));
				item.setDescription(rs.getString("description"));
				item.setCatagory(rs.getString("category"));
				if(rs.getString("imgName") != null){
					item.setImg(rs.getString("imgName"));
				}
				swapItems.add(item);
				swap.setDirty(rs.getString("dirty").equals("true")? true:false);
				swap.setId(rs.getInt("swapId"));
				swap.setLastModified(rs.getTimestamp("lastModified"));
				swap.setStatus(rs.getString("userSwaps.status"));
				swap.setOtherName(rs.getString("users.username"));
			
				if(swaps.size() != 0){
					if(swaps.get(swaps.size()-1).getId() != swap.getId()){
						swapItems = new ArrayList<Item>();
						swapItems.add(item);
						swaps.add(swap);
					}
				}else{
					swaps.add(swap);
				}
				
				if(swaps.size() != 0){
					if(item.getOwnerId() != userId){
						swaps.get(swaps.size()-1).setOtherUser(item.getOwnerId());
					}
					Item[] swapItemsArray = new Item[swapItems.size()];
					for(int i = 0; i < swapItems.size(); i++){
						swapItemsArray[i] = swapItems.get(i);
					}
					swaps.get(swaps.size()-1).setItems(swapItemsArray);
				}
			}
		}catch(SQLException e){
			System.out.println("Error retrieving swaps");
			e.printStackTrace();
		}
		
		Swap[] swapArray = new Swap[swaps.size()];
		for(int i = 0; i< swaps.size(); i++){
			swapArray[i] = swaps.get(i);
		}

		return swapArray;
	}
	
	public int numDirtyMess(int userId){
		int numDirty = 0;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps=conn.prepareStatement(GET_NUM_DIRTY_MESS);
			ps.setInt(1, userId);
			rs= ps.executeQuery();
			if(rs.next()){
				numDirty = rs.getInt("num");
			}
		}catch(SQLException e){
			System.out.println("Error retrieving dirty messages");
			e.printStackTrace();
		}
		return numDirty;
	}
	
	public void dirtyOtherUserMess(int conversationId, int userId){
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement(DIRTY_CONVERSATION_OTHER_USER);
			ps.setInt(1, conversationId);
			ps.setInt(2, userId);
			ps.execute();
		}catch(SQLException e){
			System.out.println("Error dirtying messages");
			e.printStackTrace();
		}
	}
	
	public void cleanConversation(int conversationId, int userId){
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement(CLEAN_CONVERSATION);
			ps.setInt(1, conversationId);
			ps.setInt(2, userId);
			ps.execute();
		}catch(SQLException e){
			System.out.println("Error cleaning messages");
			e.printStackTrace();
		}	
	}
	
	public int numDirtySwaps(int userId){
		int numDirty = 0;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps=conn.prepareStatement(GET_NUM_DIRTY_SWAPS);
			ps.setInt(1, userId);
			rs= ps.executeQuery();
			if(rs.next()){
				numDirty = rs.getInt("num");
			}
		}catch(SQLException e){
			System.out.println("Error retrieving dirty swaps");
			e.printStackTrace();
		}
		return numDirty;
	}
	
	public int swapDirty(int swapId, int userId, boolean dirty){
		PreparedStatement ps = null;
		int success = 2;
		String sql = "";
		if (dirty) sql = DIRTY_SWAP;
		else sql = CLEAN_SWAP;
		try{
			ps = conn.prepareStatement(sql);
			ps.setInt(1, swapId);
			ps.setInt(2, userId);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Error cleaning swap");
			e.printStackTrace();
		}
		return success;
	}
	
	public int cancelSwap(int swapId){
		int success = 2;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(CANCEL_SWAP);
			ps.setInt(1, swapId);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Error canelling swap");
			e.printStackTrace();
		}
		
		return success;
	}
	
	public int acceptSwap(int swapId){
		int success = 2;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(ACCEPT_SWAP);
			ps.setInt(1, swapId);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Error accepting swap");
			e.printStackTrace();
		}
		
		return success;
	}
	
	public int changeSwapStatus(int swapId, int userId, String status){
		int success = 2;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(UPDATE_SWAP_STATUS);
			ps.setString(1, status);
			ps.setInt(2, swapId);
			ps.setInt(3, userId);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Error accepting swap");
			e.printStackTrace();
		}
		
		return success;
	}
	
	public int getOtherSwapUser(int swapId, int userId){
		int otherUser = -1;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps=conn.prepareStatement(GET_OTHER_SWAP_USER);
			ps.setInt(1, swapId);
			ps.setInt(2, userId);
			rs= ps.executeQuery();
			if(rs.next()){
				otherUser = rs.getInt("userSwaps.userId");
			}
		}catch(SQLException e){
			System.out.println("Error retrieving other user");
			e.printStackTrace();
		}
		return otherUser;
	}
	
	public int removeItemsFromSwaps(int swapId){
		int success = 2;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(REMOVE_ITEMS_FROM_SWAP);
			ps.setInt(1, swapId);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Error removing items from swap");
			e.printStackTrace();
		}
		
		return success;
	}
	
	public int getNumReviews(int userId){
		int numReviews = 0;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(GET_NUM_REVIEWS);
			ps.setInt(1, userId);
			ResultSet rs= ps.executeQuery();
			if(rs.next()){
				numReviews = rs.getInt("numReviews");
			}
		}catch(SQLException e){
			System.out.println("Error counting reviews");
			e.printStackTrace();
		}
		
		return numReviews;
	}
	
	public Review [] getReviews(int userId , int offset){
		ArrayList<Review> reviews = new ArrayList<Review>();
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(GET_REVIEWS);
			ps.setInt(1, userId);
			ps.setInt(2, offset);
			ps.setInt(3, 10);
			ResultSet rs= ps.executeQuery();
			while(rs.next()){
				java.util.Date date = new java.util.Date();
				date.setTime(rs.getDate("createdAt").getTime());
				Review review = new Review(rs.getString("title"), rs.getString("content"), rs.getString("users.username"), rs.getInt("reviews.reviewerId"), rs.getDouble("rating"), date);
				review.setId(rs.getInt("reviewId"));
				reviews.add(review);
			}
		}catch(SQLException e){
			System.out.println("Error retrieving reviews");
			e.printStackTrace();
		}
		
		Review [] rs = new Review[reviews.size()];
		for(int i = 0; i<reviews.size(); i++){
			rs[i] = reviews.get(i);
		}
		return rs;
	}
	
	/**
	 * reviewStatus = 0 - Something is very, very wrong. Fire your coder.
	 * reviewStatus = 1 - All is good, review away
	 * reviewStatus = 2 - Review is already written. Silly, you did this already
	 * reviewStatus = 3 - This review shouldn't be written yet (or at all)!
	 * @param swapId
	 * @param userId
	 * @return reviewStatus, containing the code representing the success or error message for the userReview
	 */
	public int checkReview(int swapId, int userId){
		int reviewStatus = 0;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps = conn.prepareStatement(NEEDS_REVIEW);
			ps.setInt(1, swapId);
			ps.setInt(2, userId);
			rs = ps.executeQuery();
			if(rs.next()){
				reviewStatus = 1;
			}else{
				reviewStatus = 3;
			} 
		}catch(SQLException e){
			System.out.println("Error checking review status");
		}
		
		return reviewStatus;
	}
	
	public boolean isNewSwapConv(int swapId){
		boolean newSwap = false;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps = conn.prepareStatement(IS_NEW_CONVERSATION);
			ps.setInt(1, swapId);
			rs = ps.executeQuery();
			if(rs.next()){
				newSwap = false;
			}else{
				newSwap = true;
			}
		}catch(SQLException e){
			System.out.println("Error checking review status");
		}
		
		return newSwap;
	}
	
	
	public int getConversationId(int swapId){
		int convId = -1;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps = conn.prepareStatement(GET_CONVERSATION_ID_BY_SWAP);
			ps.setInt(1, swapId);
			rs = ps.executeQuery();
			if(rs.next()){
				convId = rs.getInt("conversationId");
			}
		}catch(SQLException e){
			System.out.println("Error checking review status");
		}
		
		return convId;
	}
	
	public ConversationBean [] getConversations(int userId){
		ArrayList<ConversationBean> conversations = new ArrayList<ConversationBean>();
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(GET_CONVERSATIONS);
			ps.setInt(1, userId);
			ps.setInt(2, userId);
			ResultSet rs= ps.executeQuery();
			while(rs.next()){
				java.util.Date date = new java.util.Date();
				date.setTime(rs.getDate("conversations.createdAt").getTime());
				ConversationBean cb = new ConversationBean();
				cb.setId(rs.getInt("userConversations.conversationId"));
				cb.setModifiedDate(rs.getDate("lastModified"));
				cb.setOtherUser(rs.getString("username"));
				cb.setTitle(rs.getString("title"));
				cb.setDirty(rs.getString("dirty"));
				cb.setCreatedDate(rs.getDate("conversations.createdAt"));
				
				conversations.add(cb);
			}
		}catch(SQLException e){
			System.out.println("Error getting conversations");
			e.printStackTrace();
		}
		ConversationBean [] cbs = new ConversationBean[conversations.size()];
		for(int i = 0; i<conversations.size(); i++){
			cbs[i] = conversations.get(i);
		}
		return cbs;
	}
	
	public MessageBean [] getMessages(int conversationId){
		ArrayList<MessageBean> messages = new ArrayList<MessageBean>();
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(GET_MESSAGES);
			ps.setInt(1, conversationId);
			ResultSet rs= ps.executeQuery();
			while(rs.next()){
				MessageBean mb = new MessageBean();
				mb.setContent(rs.getString("content"));
				mb.setCreateDate(rs.getDate("messages.createdAt"));
				mb.setOtherUser(rs.getString("username"));
				mb.setOwnerId(rs.getInt("messages.ownerId"));
				mb.setConversationId(rs.getInt("conversationId"));
				messages.add(mb);
			}
		}catch(SQLException e){
			System.out.println("Error retrieving messages");
			e.printStackTrace();
		}
		MessageBean [] mbs = new MessageBean[messages.size()];
		for(int i = 0; i<messages.size(); i++){
			mbs[i] = messages.get(i);
		}
		return mbs;
	}
	
	public int insertNote(int authorId, int userId, String content){
		int success = 0;
		PreparedStatement ps=  null;
		try{
			ps =conn.prepareStatement(INSERT_NOTE);
			ps.setInt(1, authorId);
			ps.setInt(2, userId);
			ps.setString(3, content);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			System.out.println("Error inserting note");
			e.printStackTrace();
		}
		
		return success;
	}
	
	public Note [] getNotes(int userId){
		Note [] notesArray = null;
		ArrayList<Note> notes = new ArrayList<Note>();
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(GET_NOTES);
			ps.setInt(1, userId);
			ResultSet rs= ps.executeQuery();
			while(rs.next()){
				Note note = new Note();
				note.setUserId(rs.getInt("authorId"));
				note.setUserName(rs.getString("username"));
				note.setContent(rs.getString("content"));
				notes.add(note);
			}
		}catch(SQLException e){
			System.out.println("Error retrieving messages");
			e.printStackTrace();
		}
		notesArray = new Note[notes.size()];
		for(int i = 0; i<notes.size(); i++){
			notesArray[i] = notes.get(i);
		}
		return notesArray;
	}
	
	public int addConversation(int swapId, String title){
		int conversationId = -1;
		PreparedStatement ps = null;
		ResultSet rs =null;
		try{
			ps = conn.prepareStatement(ADD_CONVERSATION, Statement.RETURN_GENERATED_KEYS);
			ps.setInt(1, swapId);
			ps.setString(2, title);
			ps.executeUpdate();
			rs = ps.getGeneratedKeys();
			conversationId = rs.next() ? rs.getInt(1) : -1;
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error adding conversations");
		}
		
		return conversationId;
	}
	
	public int addUserConversation(int userId,int conversationId, String dirty){
		int success = 0;
		PreparedStatement ps = null;
		
		try{
			ps=conn.prepareStatement(ADD_USER_CONVERSATION);
			ps.setInt(1, userId);
			ps.setInt(2, conversationId);
			ps.setString(3, dirty);
			ps.execute();
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error adding user to conversation");
		}
		return success;
	}
	public int addMessage(int userId, int conversationId, String content){
		int success = 0;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(ADD_MESSAGE);
			ps.setInt(1,userId);
			ps.setInt(2,conversationId);
			ps.setString(3, content);
			ps.execute();
			success = 1;
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error adding message");
		}
		return success;
	}
	
	public ConversationBean [] searchConversations(String query, int userId){
		ConversationBean convsArr[] = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		ArrayList<ConversationBean> convs= new ArrayList<ConversationBean>();
		try{
			ps = conn.prepareStatement(SEARCH_CONVERSATIONS_ALL);
			ps.setString(1, query);
			ps.setString(2, query);
			ps.setString(3, query);
			ps.setInt(4, userId);
			ps.setInt(5, userId);
			rs = ps.executeQuery();
			while(rs.next()){
				ConversationBean conv = new ConversationBean();
				conv.setTitle(rs.getString("title"));
				conv.setModifiedDate(rs.getDate("lastModified"));
				conv.setId(rs.getInt("conversationId"));
				conv.setOtherUser(rs.getString("username"));
				conv.setDirty(rs.getString("dirty"));
				convs.add(conv);
			}
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error searching conversations");
		}
		
		convsArr = new ConversationBean[convs.size()];
		for (int i=0; i<convs.size(); i++){
			convsArr[i] = convs.get(i);
		}
		
		return convsArr;
	}
	
	public UserBean[] getFriends(int userId){
		PreparedStatement ps = null;
		ResultSet rs= null;
		UserBean [] usersArr = null;
		ArrayList<UserBean> users = new ArrayList<UserBean>();
		
		try{
			ps = conn.prepareStatement(GET_FRIENDS);
			ps.setInt(1, userId);
			ps.setInt(2, userId);
			rs = ps.executeQuery();
			while(rs.next()){
				UserBean user = new UserBean();
				user.setId(rs.getInt("users.userId"));
				user.setName(rs.getString("username"));
				users.add(user);
			}
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error retrieving friends");
		}
		
		usersArr = new UserBean [users.size()];
		for(int i = 0; i <users.size(); i++){
			usersArr[i] = users.get(i);
		}
		
		return usersArr;
	}
	
	public int setItemsSwapped(int swapId){
		int success = 0;
		PreparedStatement ps = null;
		try{
			ps= conn.prepareStatement(SET_ITEMS_SWAPPED);
			ps.setInt(1, swapId);
			ps.execute();
			ps=conn.prepareStatement(SET_OTHER_SWAPS_CANCEL);
			ps.setInt(1, swapId);
			ps.setInt(2, swapId);
			ps.execute();
			success =1;
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error setting other items swapped.");
			success = -1;
		}
	
		return success;
	}
	
	public String [] getFaveSearches(int userId){
		String faveSearchesArr[];
		ArrayList<String> faveSearches= new ArrayList<String>();
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps = conn.prepareStatement(GET_FAVE_SEARCHES);
			ps.setInt(1,userId);
			rs = ps.executeQuery();
			while(rs.next()){
				faveSearches.add(rs.getString("searchTerm"));
			}
			
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error retrieving faveSearches");
		}
		
		faveSearchesArr = new String [faveSearches.size()];
		for(int i = 0; i< faveSearches.size(); i++){
			faveSearchesArr[i] = faveSearches.get(i);
		}
		
		return faveSearchesArr;
		
	}
	
	public int removeFaveSearch(int userId, String searchTerm){
		int success = -1;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(REMOVE_FAVE_SEARCH);
			ps.setInt(1,userId);
			ps.setString(2,searchTerm);
			ps.execute();
			success=1;
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error removing fave search");
		}
		return success;
	}
	
	public int addFaveSearch(int userId, String searchTerm){
		int success = -1;
		PreparedStatement ps = null;
		try{
			ps = conn.prepareStatement(ADD_FAVE_SEARCH);
			ps.setInt(1,userId);
			ps.setString(2,searchTerm);
			ps.execute();
			success=1;
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error add fave user");
		}
		return success;
	}
	
	public String getNews(){
		String news ="";
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps = conn.prepareStatement(GET_NEWS);
			rs= ps.executeQuery();
			while(rs.next()){
				news = rs.getString("news");
			}
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error retreiving news");
		}
		return news;
	}
	
	public Item[] getFaveSearchItems(int userId){
		Item faveSearchItemsArr[];
		ArrayList<Item> faveSearchItems= new ArrayList<Item>();
		ArrayList<String> faveSearches = new ArrayList<String>();
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			ps = conn.prepareStatement(GET_FAVE_SEARCHES);
			ps.setInt(1,userId);
			rs = ps.executeQuery();
			while(rs.next()){
				faveSearches.add(rs.getString("searchTerm"));
			}
			
			for(int i =0; i<faveSearches.size();i++){
				ps = conn.prepareStatement(GET_FAVE_SEARCH_ITEMS);
				ps.setString(1, faveSearches.get(i));
				rs = ps.executeQuery();
				while(rs.next()){
					Item item = new Item();
					item.setId(rs.getInt("itemId"));
					item.setImg(rs.getString("imgName"));
					item.setName(rs.getString("name"));
					item.setOwnerId(rs.getInt("ownerId"));
					item.setRelevance(rs.getDouble("relevance"));
					item.setCreatedAt(rs.getDate("createdAt"));
					item.setDescription(rs.getString("description"));
					item.setCatagory(faveSearches.get(i));
					faveSearchItems.add(item);
				}
				
			}
			
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error retrieving faveSearches");
		}
		
		faveSearchItemsArr = new Item[faveSearchItems.size()];
		for(int i = 0; i< faveSearchItems.size(); i++){
			faveSearchItemsArr[i] = faveSearchItems.get(i);
		}
		
		return faveSearchItemsArr;
	}
	
	public Item[] getFaveUserItems(UserBean faveUsers []){
		Item faveUserItemsArr[];
		ArrayList<Item> faveUserItems= new ArrayList<Item>();
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			for(int i =0; i<faveUsers.length;i++){
				ps = conn.prepareStatement(GET_FAVE_USER_ITEMS);
				ps.setInt(1, faveUsers[i].getId());
				rs = ps.executeQuery();
				while(rs.next()){
					Item item = new Item();
					item.setId(rs.getInt("itemId"));
					item.setImg(rs.getString("imgName"));
					item.setName(rs.getString("name"));
					item.setOwnerId(rs.getInt("ownerId"));
					item.setCreatedAt(rs.getDate("createdAt"));
					item.setDescription(rs.getString("description"));

					faveUserItems.add(item);
				}
				
			}
			
		}catch(SQLException e){
			e.printStackTrace();
			System.out.println("Error retrieving faveSearchItems");
		}
		
		faveUserItemsArr = new Item[faveUserItems.size()];
		for(int i = 0; i< faveUserItems.size(); i++){
			faveUserItemsArr[i] = faveUserItems.get(i);
		}
		
		return faveUserItemsArr;
	}
	
	public boolean knownLocation(String location){
		
		return false;
	
	}
	
	public int[] getLocationByIp(String ip){
		StaticResources sr = StaticResources.getStaticResources();
		TreeMap<Double, Integer> blockRows = sr.getblockMap();
		int [] granSizes = sr.getGranSizes();
		PreparedStatement ps = null;
		ResultSet rs = null;
		double [] coor = new double[4];
		int [] blocks = {-1,-1,-1,-1,-1,-1};
		System.out.println("IP:" + ip);
		String[] addrArray = {"0","0","0","0"};
		if(ip.indexOf(':') != -1){
			addrArray = ip.split(":");
		}else if(ip.indexOf('.') != -1){
			addrArray = ip.split("\\.");
		}
        long ipInt = 0;
        for (int i=0;i<addrArray.length;i++) {
            int power = 3-i;
            ipInt += ((Integer.parseInt(addrArray[i])%256 * Math.pow(256,power)));
        }
        System.out.println("IP2:" + ipInt);
		try{
			ps = conn.prepareStatement(GET_LAT_LONG_BY_IP);
			ps.setLong(1, ipInt);
			ps.setLong(2, ipInt);
			rs = ps.executeQuery();
			while(rs.next()){
				coor[2] = rs.getDouble("latitude");
				coor[3] = rs.getDouble("longitude");
			}
			ps = conn.prepareStatement(GET_BLOCK_BY_LAT_LONG);
			ps.setDouble(1, coor[2]);
			ps.setDouble(2, coor[2]);
			ps.setDouble(3, coor[3]);
			ps.setDouble(4, coor[3]);
			rs = ps.executeQuery();
			while(rs.next()){
				coor[0] = rs.getDouble("latTL");
				coor[1] = rs.getDouble("longTL");
				blocks[0] = rs.getInt("blockId");
				blocks[1] = (int)((((int)((coor[2]-coor[0])/(0.44914/granSizes[0])))*granSizes[0]) + ((coor[3]-coor[1])/((int)((360/blockRows.get(coor[1])))/granSizes[0])));
				blocks[2] = (int)((((int)((coor[2]-coor[0])/(0.44914/granSizes[1])))*granSizes[1]) + ((coor[3]-coor[1])/((int)((360/blockRows.get(coor[1])))/granSizes[1])));
				blocks[3] = (int)((((int)((coor[2]-coor[0])/(0.44914/granSizes[2])))*granSizes[2]) + ((coor[3]-coor[1])/((int)((360/blockRows.get(coor[1])))/granSizes[2])));
				blocks[4] = Long.valueOf(Math.round((coor[2]*10000))).intValue();
				blocks[5] = Long.valueOf(Math.round((coor[3]*10000))).intValue();
				System.out.println("Pos:" + coor[0] + " : " + coor[1] + " : " + coor[2] + " : " + coor[3]);
				System.out.println("Blocks:" + blocks[0] + " : " + blocks[1] + " : " + blocks[2] + " : " + blocks[3]);
			}
		}catch(Exception e){
			e.printStackTrace();
			System.out.println("Error retrieving user location");
			blocks = null;
		}
		if(blocks != null){
			if(blocks[0] == -1) blocks = null;
		}
		return blocks;
	}
	
	public void testSearches(int its, int range, String size, String table, String db){
		PreparedStatement ps = null;
		ResultSet rs = null;
		StaticResources sr = StaticResources.getStaticResources();
		TreeMap<Double, Integer> blockRows = sr.getblockMap();
		for(int i = 0; i<its; i++){
			try{
				double lat = 0.0;
				double lon = 0.0;
				int [] loc = {-1};
				Double [] rowSet = {-1.00};
				
				if(size.equals("large")){
					while(loc[0] == -1){
						loc = getLocationByIp(String.valueOf(Math.round(Math.random()*2147483647)));
					}
					lat = ((double)loc[4])/10000;
					lon = ((double)loc[5])/10000;
					Double nextLatRow = 0.0;
					for(Map.Entry<Double, Integer> blockMap : blockRows.entrySet()){
						nextLatRow = blockMap.getKey();
						if (blockMap.getValue() > lat) break;
					}
					rowSet = new Double [] {blockRows.lowerEntry(blockRows.lowerEntry(nextLatRow).getKey()) == null ? new Double(-1): blockRows.lowerEntry(blockRows.lowerEntry(nextLatRow).getKey()).getKey(), blockRows.lowerEntry(nextLatRow).getKey(),nextLatRow,blockRows.higherEntry(nextLatRow) == null ? new Double(-1): blockRows.higherEntry(nextLatRow).getKey(), nextLatRow,blockRows.higherEntry(nextLatRow) == null ? new Double(-1): blockRows.higherEntry(blockRows.higherEntry(nextLatRow).getKey()) == null ? new Double(-1):blockRows.higherEntry(blockRows.higherEntry(nextLatRow).getKey()).getKey()};
					
				}else if(size.equals("small")){
					loc = new int [] {((int)(Math.floor(Math.random()*9))+1), ((int)(Math.floor(Math.random()*4))+1), ((int)(Math.floor(Math.random()*25))+1), ((int)(Math.floor(Math.random()*100))+1)};
					lat = -.675 + (Math.random() * 1.35);
					lon = -.675 + (Math.random() * 1.35);
					rowSet = new Double [] {Double.valueOf((double)1),Double.valueOf((double)2),Double.valueOf((double)3),Double.valueOf((double)4),Double.valueOf((double)5),Double.valueOf((double)6),Double.valueOf((double)7),Double.valueOf((double)8),Double.valueOf((double)9)};
				}
				
				System.out.println("Querying- lat:" + lat + " lon:" + lon + " sub:" + loc[3]);
				ps = conn.prepareStatement(TRIG_SEARCH);
				ps.setDouble(1, lat);
				ps.setDouble(2, lon);
				ps.setInt(3, 50);
				for(int j = 4; j<13; j++){
					ps.setDouble(j, (1000*rowSet[j-4]));
				}
				System.out.println(ps.toString());
				//rs= ps.executeQuery();
				//rs.close();
				ps = conn.prepareStatement(CIRCLE_GEOM);
				ps.setDouble(1, lat);
				ps.setDouble(2, lat);
				ps.setDouble(3, lon);
				ps.setInt(4, 50);
				for(int j = 5; j<14; j++){
					ps.setDouble(j, (1000*rowSet[j-5]));
				}
				System.out.println(ps.toString());
				//rs= ps.executeQuery();
				//rs.close();
				ps = conn.prepareStatement(MY_SEARCH_WHERE_LIMIT_9);
				for(int j =1; j<10; j++){
					ps.setDouble(j, (1000*rowSet[j-1]));
				}
				ps.setInt(10, loc[3]);
				ps.setInt(11, 50);
				//for(int j =11; j<20; j++){
				//	ps.setDouble(j, (1000*rowSet[j-11]));
				//}
				System.out.println(ps.toString());
				//rs= ps.executeQuery();
				//rs.close();
				if(db.equals("postgres")){	
					ps = conn.prepareStatement(ST_DWITHIN_SHEREOID);
					ps.setDouble(1, lon);
					ps.setDouble(2, lat);
					ps.setInt(3, 44500);
					System.out.println(ps.toString());
					//rs= ps.executeQuery();
					//rs.close();
 					ps = conn.prepareStatement(ST_DWITHIN_SHERE);
 					ps.setDouble(1, lon);
 					ps.setDouble(2, lat);
 					ps.setInt(3, 44500);
 					System.out.println(ps.toString());
 					//rs= ps.executeQuery();
 					//rs.close();
				}else if(db.equals("mysql")){
					
				}
				conn.close();
				conn = cm.getConnection("postgres");
			}catch(SQLException e){
				e.printStackTrace();
				System.out.println("Error testing search functions");
			}
		}
	}
}