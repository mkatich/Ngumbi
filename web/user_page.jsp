<%-- 
    Document   : user_page
    Created on : 
    Author     : Michael

    Description: Retrieves links and search option from MySQL database
        and displays links on webpage in organized way.
    
--%>

<%@page import="DbConnectionPool.DbConnectionPool"%>
<%@ page language="java" import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="logon" scope="session" class="logonBean.logon" /> 
<jsp:useBean id="helperMethods" scope="page" class="helperMethodsBean.helperMethods" />

<%
//get the username which was passed as an argument ? thing
String user = request.getParameter("user");

boolean userExists = false;

String errorMsg = "";


//defaults, these are used when there is no parameter passed, it's white
String linkColor = "#0000cc";
String visitedColor = "#800080";
String hoverColor = "#800080";
String activeColor = "#ff0000";
String bgColor = "ffffff";
String textColor = "000000";

//String fontSize = "-1";
String fontFamily = "arial,sans-serif,helvetica";




//get other user data
String qUserData = "SELECT searchOption, searchUrl, searchLang FROM users WHERE username = ? ";
PreparedStatement psUserData = null;
ResultSet rsUserData = null;
int searchFlag = 0;
String searchUrl = "";
String searchLang = "";

//get user links
String qUserLinks = ""
        + "SELECT "
        + "ul.link_name AS link_name, ul.link_address AS link_address, ul.cat AS cat, ul.sub_cat_rank AS sub_cat_rank "
        + "FROM user_links ul LEFT JOIN users u ON (ul.user_id = u.user_id) "
        + "WHERE u.username = ? "
        + "ORDER BY cat_rank, sub_cat_rank, link_rank";
PreparedStatement psUserLinks = null;
ResultSet rsUserLinks = null;
String[][] links = null;

Connection conn = null;
try {
    conn = DbConnectionPool.getConnection();//fetch a connection
    if (conn != null){
        //perform queries
        
        //get user data (metadata, not links)
        psUserData = conn.prepareStatement(qUserData);
        psUserData.setString(1, user);
        rsUserData = psUserData.executeQuery();
        
        if (rsUserData.next()){
            searchFlag = rsUserData.getInt("searchOption");
            searchUrl = rsUserData.getString("searchUrl");
            searchLang = rsUserData.getString("searchLang");
            
            userExists = true;
            
            //		**ADMIN UPDATE**	
            //update the last viewed value in users table
            //checks reporting turned on, then adds entry to history table for this view, while deleting oldest entry
            helperMethods.adminUpdate(user, "view");
        }
        
        //get user links
        psUserLinks = conn.prepareStatement(qUserLinks);
        psUserLinks.setString(1, user);
        rsUserLinks = psUserLinks.executeQuery();
        
        int countUserLinks = 0;
        while (rsUserLinks.next()){
            countUserLinks++;
        }
        rsUserLinks.beforeFirst();
        
        links = new String[countUserLinks][4];
        countUserLinks = 0;
        while (rsUserLinks.next()){
            String currCat = rsUserLinks.getString("cat");
            String currSubCatRank = rsUserLinks.getString("sub_cat_rank");
            String currLinkAddr = rsUserLinks.getString("link_address");
            String currLinkName = rsUserLinks.getString("link_name");
            
            links[countUserLinks][0] = currCat;
            links[countUserLinks][1] = currSubCatRank;
            links[countUserLinks][2] = currLinkAddr;
            links[countUserLinks][3] = currLinkName;
            
            countUserLinks++;
        }
        
    }
}
catch (SQLException e) {
    DbConnectionPool.outputException(e, "user_page.jsp", 
            new String[]{"qUserData", qUserData, "qUserLinks", qUserLinks});
    errorMsg = "There was an error retrieving your page.";
}
finally {
    DbConnectionPool.closeResultSet(rsUserData);
    DbConnectionPool.closeStatement(psUserData);
    DbConnectionPool.closeResultSet(rsUserLinks);
    DbConnectionPool.closeStatement(psUserLinks);
    DbConnectionPool.closeConnection(conn);
}





%>
<html>
<head>
<title><%=user%> &#64; ngumbi.com</title>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link rel="stylesheet" type="text/css" href="../style.css">
<style type="text/css">
<!--

a:link{	color:<%=linkColor%>; 
		text-decoration:underline;
		font-family:<%=fontFamily%>;}
a:visited{	color:<%=visitedColor%>; 
			text-decoration:underline;
			font-family:<%=fontFamily%>;}
a:hover {	color:<%=hoverColor%>; 
			text-decoration:none;
			font-family:<%=fontFamily%>;}
a:active {	color:<%=activeColor%>; 
			text-decoration:none;
			font-family:<%=fontFamily%>;}
body { 	background-color: <%=bgColor%>; 
		color: <%=textColor%>;
		font-family:<%=fontFamily%>;}

a.user_link {
    font-size: .8em;
}

-->
</style>

<jsp:include page="inc_google_analytics.jsp" />
</head>
<body>
    
    <%
        

    //check if username exists
    if (userExists){
        //it exists, continue
        
        //Show current date and time
        %>
        <!--<%= new java.util.Date() %>	-->
        
        <!-- Start Page Header (top table) -->
        <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <tr valign="top">
                <td valign="top" style="text-align: center;">
                    <%

                    //Search check, flag is 
                    //	0 - no search 
                    // 	1 - ngumbi branded google search (default)
                    //	2 - regular google search
                    //	3 - ngumbi branded safe google search
                    //	10 - yahoo search
                    if (searchFlag == 0){
                        //0 - no search 
                    }
                    //else if (searchFlag == 2){
                        //2 - regular google search

                    //}
                    //else if (){
                    //
                    //}
                    else if (searchFlag >= 1 && searchFlag <= 9){
                        //1-9: we have some form of google search
                        boolean useGoogleCse = false;
                        String searchSuffix2 = "search";

                        if (searchFlag == 1 || searchFlag == 3){
                            //both search type 1 and 3 use adsense branded custom search engine
                            searchSuffix2 = "cse";
                            useGoogleCse = true;//google.com/cse, ngumbi branded
                        }



                        %>

                        <!-- Search Google -->
                        <form name="search_form" action="http://<%=searchUrl%>/<%=searchSuffix2%>" id="cse-search-box">
                          <div>
                            <a href="http://<%=searchUrl%>/" style="text-decoration: none;">
                                <img src="http://www.google.com/logos/Logo_40wht.gif" border="0" alt="Google" align="middle">
                            </a>
                            <%
                            if (useGoogleCse){
                                //put in the adsense custom search partner code
                                %><input type="hidden" name="cx" value="partner-pub-8335750690638492:1547181858" /><%
                            }

                            if (searchFlag == 3){
                                //enable safe search strict here
                                %><input type="hidden" name="safe" value="active" /><%
                            }
                            %>
                            <input type="hidden" name="ie" value="UTF-8" />
                            <input type="hidden" name="hl" value="<%=searchLang%>">
                            <input type="text" name="q" size="31" />
                          </div>
                        </form>
                        <!-- end Search Google -->

                        <!--set focus to the search form text box in javascript-->
                        <script type="text/javascript"><!--
                        document.search_form.q.focus();
                        //--></script>

                        <%
                    }// end 1,2,3 google Search

                    else if (searchFlag == 10){
                        //10: yahoo search

                        %>
                        <!-- Yahoo! Search -->
                        <form name="myform" method=get action="http://<%=searchUrl%>/search" style="padding: 5px; width:360px; text-align:center; margin-top: 15px; margin-bottom: 25px; margin-left: auto; margin-right: auto;">
                            <a href="http://<%=searchUrl%>/"><img src="http://us.i1.yimg.com/us.yimg.com/i/us/search/ysan/ysanlogo.gif" alt="yahoo" align="absmiddle" border=0></a>
                            <input type="text" name="p" size=25>&nbsp;
                            <input type="hidden" name="fr" value="yscpb">&nbsp;
                            <input type="submit" value="Search">
                        </form>
                        <!-- End Yahoo! Search -->

                        <!--set focus to the search form text box in javascript-->
                        <script type="text/javascript"><!--
                        document.myform.p.focus();
                        //--></script>

                        <%
                    }	
                    %>

                </td>
                <td align="right" valign="top">

                    <% // The "Edit" link in top right, passes username so editor.jsp can require login.
                    if (!logon.getSecure()){ //haven't edited before in this browser session
                        %><a href="../editor.jsp?user=<%=user%>&state=1&fromstate=0">Edit</a><%
                    }
                    else { //they did edit before, skip login screen since it will authenticate already
                        %><a href="../editor.jsp?user=<%=user%>&state=2&fromstate=0">Edit</a><%
                    }


                    %>
                </td>
            </tr>
        </table>
        <!-- End Start Page Header (top table) -->



        <!-- start main table -->
        <table cellpadding="0" cellspacing="8" border="0" style="margin-left: auto; margin-right: auto;"><%
            
            
            int linkCounter = 0;
            int catCounter = 0;
            String currCat = "";
            String currSubCatRank = "";
            String currLinkAddr = "";
            String currLinkName = "";
            String lastCat = "";
            String lastSubCatRank = "";
            
            //do the first link
            if (links.length > 0){
                currCat = links[linkCounter][0].replace('+',' ');//have to get first table entry to assign tracking variables
                currSubCatRank = links[linkCounter][1];//of current category and subcategory
                currLinkAddr = links[linkCounter][2];
                currLinkName = links[linkCounter][3].replace('+',' ');
                
                //check if first link is a category-less one
                if (currCat.equals("")){
                    //first link doesn't have category
                    %><!-- start table and print first link centered-->
                    <tr><td valign="top" colspan="2"><center>
                    <a href="<%=currLinkAddr%>" class="user_link"><%=currLinkName%></a>&nbsp;&nbsp;<%
                }
                
                else {
                    //first link does have category, print first category, then first link
                    %><tr><td valign="top" width="50%"><STRONG><%=currCat%></STRONG><br>
                    <a href="<%=currLinkAddr%>" class="user_link"><%=currLinkName%></a>&nbsp;&nbsp;<%
                    catCounter++;
                    lastCat = currCat;
                }
                
                lastSubCatRank = currSubCatRank;
                linkCounter++;
            }

            // first link is completed, now loop through rest
            for (int i = 1; i < links.length; i++){
                currCat = links[linkCounter][0].replace('+',' ');//have to get first table entry to assign tracking variables
                currSubCatRank = links[linkCounter][1];//of current category and subcategory
                currLinkAddr = links[linkCounter][2];
                currLinkName = links[linkCounter][3].replace('+',' ');

                if (!(currCat.equals(lastCat))){
                    //we have a new category so indent accordingly
                    catCounter++;
                    
                    if (((catCounter%2) == 0) && !(lastCat.equals(""))){//we are still in the same row of big table, don't <tr> yet
                        //also, have new category but last category wasn't null, so don't start new line under category-less pool
                        %></td><td valign="top" width="50%"><strong><%=currCat%></strong><br><a href="<%=currLinkAddr%>" class="user_link"><%=currLinkName%></a>&nbsp;&nbsp;<%
                    }
                    else { // we jumped to next row of big table, do <tr>
                        %></td></tr><tr><td valign="top"><strong><%=currCat%></strong><br><a href="<%=currLinkAddr%>" class="user_link"><%=currLinkName%></a>&nbsp;&nbsp;<%

                        if (lastCat.equals("")){//we're on 1st new category since the category-less pool
                            //do nothing, already accounted for
                        }
                    }
                }

                else {
                    //we are still in same category (or non-category)
                    if (!currSubCatRank.equals(lastSubCatRank)){
                        //we are in a new subcategory, do <br>
                        %><br><a href="<%=currLinkAddr%>" class="user_link"><%=currLinkName%></a>&nbsp;&nbsp;<%		
                    }
                    else{
                        //we are in same category and subcategory  
                        %><a href="<%=currLinkAddr%>" class="user_link"><%=currLinkName%></a>&nbsp;&nbsp;<%
                    }	
                }

                lastCat = currCat;
                lastSubCatRank = currSubCatRank;
                linkCounter++;
                
                //do newline after link
                //this prevents html for links from all being on same line, and
                //not spacing and wrapping properly in some browsers
                %>
                <% 	
            } 	

            %>
            </td>
            </tr>
        </table>
        <!-- End main table -->



        <!-- list total links and categories -->
        <p style="text-align: center; font-size: .8em; padding-bottom: 20px;">
            Displaying <b><%=linkCounter%></b> links
            <%
            //display count of categories only if had any
            if (catCounter > 0){
                %> in <b><%=catCounter%></b> categories<%
            }    
            %>
            <br>
            <a href="../index.jsp">ngumbi</a>
        </p>


        <%

    }//end if userExists
    else {
        errorMsg = "You've entered an invalid username ("+user+")";
    }
    
    if (!errorMsg.equals("")){
        %>
        <div class="main">
            <jsp:include page="inc_ngumbi_title_childlevel_unlinked.jsp" />
            <p><%=errorMsg%></p>
            <p>Go to <a href="../index.jsp">ngumbi home</a></p>
        </div>
        <%
    }
    
    %>
</body>
</html>
