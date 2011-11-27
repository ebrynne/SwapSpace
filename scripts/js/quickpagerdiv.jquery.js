//-------------------------------------------------
//		Quick Pager jquery plugin
//		Created by dan and emanuel @geckonm.com
//		www.geckonewmedia.com
// 
//		v1.1
//		18/09/09 * bug fix by John V - http://blog.geekyjohn.com/
//-------------------------------------------------

(function($) {
	    
	$.fn.quickPager = function(options) {
	
		var defaults = {
			pageSize: 10,
			currentPage: 1,
			holder: null,
			pagerLocation: "after"
		};
		
		var options = $.extend(defaults, options);
		
		
		return this.each(function() {
	
						
			var selector = $(this);	
			var pageCounter = 1;
			
			selector.wrap("<div class='simplePagerContainer'></div>");
			
			selector.children().each(function(i){ 
					if(i < pageCounter*options.pageSize && i >= (pageCounter-1)*options.pageSize) {
					$(this).addClass("simplePagerPage"+pageCounter);
					}
					else {
						$(this).addClass("simplePagerPage"+(pageCounter+1));
						pageCounter ++;
					}	
			});
			
			// show/hide the appropriate regions 
			selector.children().hide();
			selector.children(".simplePagerPage"+options.currentPage).show();
			
			if(pageCounter <= 1) {
				return;
			}
			
			//Build pager navigation
			var pageNav = "<div class='conv pagerN'><ul class='simplePagerNav'>";	
			for (i=1;i<=pageCounter;i++){
				if(i==pageCounter){
					pageNav += "<li class='endDot'>&nbsp;. . .&nbsp;</li>";
				}
				if (i==options.currentPage) {
					pageNav += "<li class='currentPage simplePageNav"+i+"'><a rel='"+i+"' href='#'>"+i+"</a></li>";	
				}
				else {
					pageNav += "<li class='simplePageNav"+i+"'><a rel='"+i+"' href='#'>"+i+"</a></li>";
				}
				if(i==1){
					pageNav += "<li class='oneDot'>&nbsp;. . .&nbsp;</li>";
				}
			}
			pageNav += "</ul></div>";
			
			
			if(!options.holder) {
				switch(options.pagerLocation)
				{
				case "before":
					selector.before(pageNav);
				break;
				case "both":
					selector.before(pageNav);
					selector.after(pageNav);
				break;
				default:
					selector.append(pageNav);
				}
			}
			else {
				$(options.holder).append(pageNav);
			}
			selector.find(".oneDot").hide();
			selector.find(".endDot").hide();
			//pager navigation behaviour
			selector.parent().find(".simplePagerNav a").click(function() {
					
				//grab the REL attribute 
				var clickedLink = $(this).attr("rel");
				j = clickedLink*1;
				options.currentPage = clickedLink;
				
				if(options.holder) {
					$(this).parent("li").parent("ul").parent(options.holder).find("li.currentPage").removeClass("currentPage");
					$(this).parent("li").parent("ul").parent(options.holder).find("a[rel='"+clickedLink+"']").parent("li").addClass("currentPage");
				}
				else {
					//remove current current (!) page
					$(this).parent("li").parent("ul").find("li.currentPage").removeClass("currentPage");
					//Add current page highlighting
					$(this).parent("li").addClass("currentPage");
				}
				
				//hide and show relevant links
				selector.children().hide();			
				selector.children(".pagerN").show();
				pageNav = selector.children(".pagerN").children();
				pageNav.show();
				pageNav.children().hide();
				
				pageNav.children(".simplePageNav"+(clickedLink-3)).show();
				pageNav.children(".simplePageNav"+(clickedLink-2)).show();
				pageNav.children(".simplePageNav"+(clickedLink-1)).show();
				pageNav.children(".simplePageNav"+clickedLink).show();
				pageNav.children(".simplePageNav"+(j+1)).show();
				pageNav.children(".simplePageNav"+(j+2)).show();
				pageNav.children(".simplePageNav"+(j+3)).show();
				if(clickedLink+3 < pageCounter){
					pageNav.children(".endDot").show();
					pageNav.children(".simplePageNav"+pageCounter).show();
				}
				if(clickedLink-3 > 1){
					pageNav.children(".oneDot").show();
					pageNav.children(".simplePageNav"+1).show();
				}
				selector.find(".simplePagerPage"+clickedLink).show();
				
				return false;
			});
		});
	}
	

})(jQuery);

