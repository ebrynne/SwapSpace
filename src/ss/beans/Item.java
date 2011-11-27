package ss.beans;

import java.sql.Date;

public class Item extends ResultObject implements java.io.Serializable{
 
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int ownerId;
	private String description = "";
	private String category = "";
	private int swapId;
	private Date createdAt = null;
	
	public void setOwnerId(int ownerId) {
		this.ownerId = ownerId;
	}
	public int getOwnerId() {
		return ownerId;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getDescription() {
		return description;
	}
	public void setCatagory(String catagory) {
		this.category = catagory;
	}
	public String getCatagory() {
		return category;
	}
	public void setSwapId(int swapId) {
		this.swapId = swapId;
	}
	public int getSwapId() {
		return swapId;
	}
	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}
	public Date getCreatedAt() {
		return createdAt;
	}
}
