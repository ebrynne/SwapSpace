package ss.beans;

import java.sql.Date;

public class ConversationBean extends UniqueDBO {
	private Date createdDate;
	private Date modifiedDate;
	private String title;
	private String otherUser;
	private String dirty;
	public void setTitle(String title) {
		this.title = title;
	}
	public String getTitle() {
		return title;
	}
	public void setOtherUser(String otherUser) {
		this.otherUser = otherUser;
	}
	public String getOtherUser() {
		return otherUser;
	}
	public void setModifiedDate(Date modifiedDate) {
		this.modifiedDate = modifiedDate;
	}
	public Date getModifiedDate() {
		return modifiedDate;
	}
	public void setCreatedDate(Date createdDate) {
		this.createdDate = createdDate;
	}
	public Date getCreatedDate() {
		return createdDate;
	}
	public void setDirty(String dirty) {
		this.dirty = dirty;
	}
	public String getDirty() {
		return dirty;
	}
}
