package ss.beans;

public class Note extends UniqueDBO{
	private String content = "";
	private String userName = "";
	private int userId = -1;
	public void setContent(String content) {
		this.content = content;
	}
	public String getContent() {
		return content;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserId(int userId) {
		this.userId = userId;
	}
	public int getUserId() {
		return userId;
	}
	
}
