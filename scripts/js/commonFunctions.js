function toggleFave(faveId){
		if($("#faveHeart").attr("src") == "/img/emptyHeart.png"){
			$.ajax({
				url: "/View",
				type: "POST",
				data: "postType=addFave&faveId=" +faveId,
				cache: false,
				success: function(j){
					if(jQuery.trim(j) == "1"){
						$("#faveHeart").attr("src",  "/img/fullHeart.png");
						$("#faveHeart").attr("title",  "Unfavorite this user!");
					}
				}
			});
		}else{
			$.ajax({
				url: "/View",
				type: "POST",
				data: "postType=removeFave&faveId=" +faveId,
				cache: false,
				success: function(j){
					if(jQuery.trim(j) == "1"){
						$("#faveHeart").attr("src",  "/img/emptyHeart.png");
						$("#faveHeart").attr("title",  "Favorite this user!");
					}
				}
			});
		}
	}