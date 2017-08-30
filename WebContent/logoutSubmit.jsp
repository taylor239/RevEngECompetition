<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<%
	if(request.getParameter("removeCookie") != null){
        Cookie[] cookies = request.getCookies();

        for(int i=0;i<cookies.length;i++){

            if(!cookies[i].getName().equals("JSESSIONID")){

                cookies[i].setMaxAge(-1);
                cookies[i].setValue(null);

                response.addCookie(cookies[i]);
            }
        }
    }
	session.invalidate();
	//Database entry here
	%>
<meta http-equiv="refresh" content="0;url=index.jsp">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>RevEngE</title>

</head>
<body>
</body>