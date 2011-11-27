package ss.beans;

import java.util.Date;

public class Review extends UniqueDBO{
	private String name = "";
	private String contents = "";
	private String reviewer = "";
	private int reviewerId = -1;
	private double rating;
	private Date date;
	public Review(String name, String contents, String reviewer, int reviewerId, double rating, Date date){
		this.name = name;
		this.contents = contents;
		this.reviewer = reviewer;
		this.reviewerId = reviewerId;
		this.rating = rating;
		this.date = date;
	}
	
	public void setContents(String contents) {
		this.contents = contents;
	}
	public String getContents() {
		return contents;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getName() {
		return name;
	}
	public void setReviewer(String reviewer) {
		this.reviewer = reviewer;
	}
	public String getReviewer() {
		return reviewer;
	}
	public void setReviewerId(int reviewerId) {
		this.reviewerId = reviewerId;
	}
	public int getReviewerId() {
		return reviewerId;
	}
	public void setRating(double rating) {
		this.rating = rating;
	}
	public double getRating() {
		return rating;
	}
	public void setDate(Date date) {
		this.date = date;
	}
	public Date getDate() {
		return date;
	}
	
}
