<head>
	<link rel="shortcut icon" href="/img/favicon.ico" >
	<link rel="stylesheet" type="text/css" href="css/jquery.fancybox.css"></link>
	<script src="/jquery.fancybox.js" type="text/javascript"></script>
	<script src="/quickpagerdiv.jquery.js"></script>
	<script type="text/javascript">
	$(document).ready(function() { 
		
		$("a#loginPopup").fancybox({ 'zoomSpeedIn': 300, 'zoomSpeedOut': 300, 'overlayShow': true, 'hideOnOverlayClick': true, 'hideOnContentClick' : false,'autoDimensions':false, 'height': 350, 'width':400}); 
		$("#loginForm").submit(function(){
		});

		$("a#termsCondsBottom").fancybox({ 'zoomSpeedIn': 300, 'zoomSpeedOut': 300, 'overlayShow': true, 'hideOnOverlayClick': true, 'hideOnContentClick' : false,'autoDimensions':false, 'height':500, 'width':600}); 

		$("#searchText").focus(function(){
		    this.select();
		});

		
		$(".pageme2 ").quickPager( {
			pageSize: 2,
			currentPage: 1,
			pagerLocation: "after"
		});
		$(".pageme3 ").quickPager( {
			pageSize: 2,
			currentPage: 1,
			pagerLocation: "after"
		});
			
		
	}); 

	function loginFunction(){
		$.get("LoginServlet", {email : $("input#loginEmail").val(), password: $("input#loginPassword").val()}, function(data){
			splitData = data.split("/");
			if(splitData[0] == "Success"){
				$.fancybox.close();
				$("div#topRight").html("Welcome " + splitData[1] + "!<br />" +
				"<a href='/User?pageRequest=myItems'>My Items</a><br /> " +
				"<a href='/User?pageRequest=mySwaps'>My Swaps</a><br /> " +
				"<a href='/User?pageRequest=accountSettings'>Account Settings</a><br /> " +
				"<a href='/User?pageRequest=conversations'>Messages</a><br />" +
				"<a href='/Controller?pageRequest=logout'>Logout</a>");
				if($("#swapSection").length > 0){
					location.reload(); 
				}
			}else{
				$("#loginErrorMsg").html(data);
			}
		});
		
	}
	</script>
</head>
<div class="header">
	<div class="leftAlign" onClick="location.href='/Controller?pageRequest=home'" style="height:100px; width:100px; float:left;"></div>
	<div class="rightAlign" id="topRight">
		<jsp:include page="AccountLinks.jsp"></jsp:include>
	</div><br />
	<form id="searchForm" action="/Search">
		<img src="/img/newSearchLeft.png" class="searchLeft"></img><input type="text" id="searchText" name="search" style="background:url(/img/newSearchMid.png) repeat-x bottom left;padding:0px 0px 0px 0px;margin:0;display:inline;vertical-align: top;border:0;width:181px;height: 40px;" onFocus="this.value=''" value="            Search Here"></input><input type="image" src="/img/newSearchRight.png" alt="Search" id="searchButton" style="width:45px;height:40px;"></input>
		<input type="hidden" name="page" value="0"></input><input type="hidden" name="type" value="item"></input>
		<span style="line-height: 15px; position: relative; top: -38px; left: 120px; width: 60px;"><br><a href="/Controller?pageRequest=advancedSearch" style="font-size: 10px;">Advanced Search</a><!-- <br><% if(session.getAttribute("user")!=null){ %><a href="/Controller?pageRequest=smartSearch" style="font-size: 10px; position: relative; left: -10px;">Smart Search</a><% } %> --></span>
	</form>
</div>