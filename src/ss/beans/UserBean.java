package ss.beans;

public class UserBean extends ResultObject implements java.io.Serializable{
	private static final long serialVersionUID = -7192528193886880255L;
	private String email;
	private String location ="";
	private String active;
	private double rating;
	private String description ="";
	private String lookingFor = "";
	private String guid = "";
	
	public UserBean(){
		email ="";
		active = "Active";
	}
	
	public UserBean(String username, int userId, double rating){
		super.setId(userId);
		super.setName(username);
		this.rating = rating;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getEmail() {
		return email;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getLocation() {
		return location;
	}

	public void setActive(String active) {
		this.active = active;
	}

	public String getActive() {
		return active;
	}
	
	public boolean commit(){
		return false;
	}
	
	public void setRating(double rating){
		this.rating = rating;
	}
	
	public double getRating(){
		return rating;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getDescription() {
		return description;
	}

	public void setLookingFor(String lookingFor) {
		this.lookingFor = lookingFor;
	}

	public String getLookingFor() {
		return lookingFor;
	}

	public void setGuid(String guid) {
		this.guid = guid;
	}

	public String getGuid() {
		return guid;
	}

}
