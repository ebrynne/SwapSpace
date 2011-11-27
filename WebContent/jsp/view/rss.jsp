<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/css" href="http://localhost:8080/css/genericStyles.css" ?>
<rss version="2.0">
<%@ page import="ss.beans.Item"%>
<%@ page import="java.sql.Date"%>
<%@ page import="java.util.GregorianCalendar" %>
	<channel>
		<title>Favorite <%= request.getAttribute("type") %> RSS feed</title>
		<link>http://www.swapspace.com/</link>
		<description>RSS feed for most recent items.</description>
		<language>en-us</language>
		<% 
			String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
			String[] days = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
			Item [] items = (Item [])request.getAttribute("items");
			for(int i =0; i<items.length; i++){
				Item item = items[i];
				GregorianCalendar cal = new GregorianCalendar();
				cal.setTimeInMillis(item.getCreatedAt().getTime());
				String imgName ="/img/noimage.png";
				if(item.getImg() != null){
					if(!item.getImg().equals("")) imgName = "/img/item/"+item.getImg();
				}
		%> 
				<item>
					<title><%= item.getName() %></title>
					<link>http://localhost:8080/View?pageRequest=user&amp;user=<%= item.getOwnerId() %></link>
					<guid>http://localhost:8080/View?pageRequest=user&amp;user=<%= item.getOwnerId() %></guid>
					<pubDate><%= days[cal.DAY_OF_WEEK-1] %>, <%= cal.DAY_OF_MONTH %> <%= months[cal.MONTH-1] %> <%= cal.HOUR %>:<%= cal.MINUTE%>:<%= cal.SECOND %> GMT</pubDate>
					<description><![CDATA[<img class="itemImgSmall" style='max-width: 200px; max-height: 200px; width: expression(this.width > 200 ? "200px" : true); height: expression(this.height > 200 ? "200px" : true);' src="<%= imgName %>" ></img><br /><%= item.getDescription() %>]]></description>
				</item>
		<%} %>
	</channel>
</rss>