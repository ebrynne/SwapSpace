package ss.beans;

public class ResultObject extends UniqueDBO{
	private String name;
	private double relevance;
	private String imgName;

	public void setRelevance(double searchVal) {
		this.relevance = searchVal;
	}

	public double getRelevance() {
		return relevance;
	}
	public void setImg(String imgName) {
		this.imgName = imgName;
	}
	public String getImg() {
		return imgName;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getName() {
		return name;
	}

	
}
