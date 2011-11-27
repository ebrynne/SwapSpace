package ss.beans;

import java.util.Date;

public class Swap extends UniqueDBO{
	private boolean isDirty;
	private String status;
	private int otherUser;
	private String otherName;
	private Date lastModified;
	private Item [] items;
	public void setDirty(boolean isDirty) {
		this.isDirty = isDirty;
	}
	public boolean isDirty() {
		return isDirty;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public String getStatus() {
		return status;
	}
	public void setOtherUser(int otherUser) {
		this.otherUser = otherUser;
	}
	public int getOtherUser() {
		return otherUser;
	}
	public void setLastModified(Date lastModified) {
		this.lastModified = lastModified;
	}
	public Date getLastModified() {
		return lastModified;
	}
	public void setItems(Item [] items) {
		this.items = items;
	}
	public Item [] getItems() {
		return items;
	}
	public void setOtherName(String otherName) {
		this.otherName = otherName;
	}
	public String getOtherName() {
		return otherName;
	}
}
