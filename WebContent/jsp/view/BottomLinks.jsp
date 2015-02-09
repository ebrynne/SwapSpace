<div style="width: 500px; margin: auto; text-align: center;">
<a href="/Controller?pageRequest=home" class="tinylink">Home</a> - <a href="/Controller?pageRequest=advancedSearch" class="tinylink">Advanced Search</a> - <a href="Controller?pageRequest=contactUs" class="tinylink">Contact Us</a>
<% if(session.getAttribute("user") != null) {%><br />
<a href="/User?pageRequest=myItems" class="tinylink">My Items</a> - <a href="/User?pageRequest=mySwaps" id="swapLink" class="tinylink">My Swaps</a> - <a href="/User?pageRequest=accountSettings" class="tinylink">Account Settings</a> - <a href="/User?pageRequest=conversations" class="tinylink">Messages</a> - <a href="/Controller?pageRequest=logout" class="tinylink">Logout</a>
<% } %><br />
<a href="/Controller?pageRequest=faqs" class="tinylink">FAQS</a> - <a href="jsp/view/TermsConds.jsp" id="termsCondsBottom" class="tinylink">Terms and Conditions</a> - <a href="/Controller?pageRequest=help" class="tinylink">Guide</a>
</div>