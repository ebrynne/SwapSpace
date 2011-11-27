package ss.beans;

import java.sql.Date;

public class MessageBean extends UniqueDBO {
	private String otherUser;
	private Date createDate;
	private int ownerId;
	private int conversationId;
	private String content;
	public void setOtherUser(String otherUser) {
		this.otherUser = otherUser;
	}
	public String getOtherUser() {
		return otherUser;
	}
	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}
	public Date getCreateDate() {
		return createDate;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getContent() {
		return content;
	}
	public void setOwnerId(int ownerId) {
		this.ownerId = ownerId;
	}
	public int getOwnerId() {
		return ownerId;
	}
	public void setConversationId(int conversationId) {
		this.conversationId = conversationId;
	}
	public int getConversationId() {
		return conversationId;
	}
	
	
}
