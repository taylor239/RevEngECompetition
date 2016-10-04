<%
	myUser=(User)session.getAttribute("user");
	hasUser=myUser!=null;
	String ip=(String)session.getAttribute("ip");
	if(ip==null)
	{
		session.setAttribute("ip", request.getRemoteAddr());
	}
	else
	{
		if(!ip.equals(request.getRemoteAddr()))
		{
			//Database entry here
			hasUser=myUser!=null;
			if(hasUser)
			{
				session.invalidate();
			%>
            <jsp:forward page="./endsession.jsp" />
            <%
			}
		}
	}
	/*
	int cookielife=900;
	String auth=(String)session.getAttribute("authcookiecode");
	if(auth==null || auth.equals(""))
	{
		//SecureRandom random = new SecureRandom();
		//byte bytes[] = new byte[256];
		//random.nextBytes(bytes);
		String bytesString=UUID.randomUUID().toString();
		//new String(bytes, "UTF-8");
		bytesString=URLEncoder.encode(bytesString, "UTF-8");
		Cookie authCookie=new Cookie("authcookie", bytesString);
		authCookie.setMaxAge(cookielife);
		authCookie.setPath("/Pilar/");
		response.addCookie(authCookie);
		session.setAttribute("authcookiecode", bytesString);
	}
	else
	{
		Cookie[] cookies=request.getCookies();
		if(cookies==null)
		{
			hasUser=myUser!=null;
			if(hasUser)
			{
				session.invalidate();
			%>
				<jsp:forward page="./endsession.jsp" />
            <%
			}
			else
			{
				//SecureRandom random = new SecureRandom();
				//byte bytes[] = new byte[256];
				//random.nextBytes(bytes);
				String bytesString=UUID.randomUUID().toString();
				//new String(bytes, "UTF-8");
				bytesString=URLEncoder.encode(bytesString, "UTF-8");
				Cookie authCookie=new Cookie("authcookie", bytesString);
				authCookie.setMaxAge(cookielife);
				authCookie.setPath("/Pilar/");
				response.addCookie(authCookie);
				session.setAttribute("authcookiecode", bytesString);
			}
		}
		else
		{
			boolean good=false;
			for(int x=0; x<cookies.length; x++)
			{
				if(cookies[x].getName().equals("authcookie"))
				{
					if(cookies[x].getValue().equals(auth))
					{
						good=true;
					}
				}
			}
			if(!good)
			{
				//out.flush();
				//Database entry here
				hasUser=myUser!=null;
				if(hasUser)
				{
					session.invalidate();
				%>
            	<jsp:forward page="./endsession.jsp" />
            	<%
				}
				else
				{
					//SecureRandom random = new SecureRandom();
					//byte bytes[] = new byte[256];
					//random.nextBytes(bytes);
					String bytesString=UUID.randomUUID().toString();
					//new String(bytes, "UTF-8");
					bytesString=URLEncoder.encode(bytesString, "UTF-8");
					Cookie authCookie=new Cookie("authcookie", bytesString);
					authCookie.setMaxAge(cookielife);
					authCookie.setPath("/Pilar/");
					response.addCookie(authCookie);
					session.setAttribute("authcookiecode", bytesString);
				}
			}
			else
			{
				//SecureRandom random = new SecureRandom();
				//byte bytes[] = new byte[256];
				//random.nextBytes(bytes);
				String bytesString=UUID.randomUUID().toString();
				//new String(bytes, "UTF-8");
				bytesString=URLEncoder.encode(bytesString, "UTF-8");
				Cookie authCookie=new Cookie("authcookie", bytesString);
				authCookie.setMaxAge(cookielife);
				authCookie.setPath("/Pilar/");
				response.addCookie(authCookie);
				session.setAttribute("authcookiecode", bytesString);
			}
		}
	}
	*/
	if(request.getParameter("email")!=null && request.getParameter("password")!=null)
	{
		if(verbose)
		{
			System.out.println("Signing in");
		}
		myUser=myConnector.signIn(request.getParameter("email"), request.getParameter("password"), request.getRemoteAddr());
	}
	if(verbose)
	{
		System.out.println("Signed in");
	}
	hasUser=myUser!=null;
	if(hasUser)
	{
		/*
		myUser.changeAttribute("previousVisit", myUser.getAttribute("currentVisit"));
		myUser.changeAttribute("currentVisit", new java.sql.Timestamp(today.getTime()));
		myUser=myConnector.updateUser(myUser, myUser, request.getRemoteAddr(), request.getRequestURI());
		*/
		session.setAttribute("user", myUser);
		if(((Boolean)myUser.getAttribute("displayRealName")))
		{
			displayName=((String)myUser.getAttribute("fName"))+" "+((String)myUser.getAttribute("mName"))+" "+((String)myUser.getAttribute("lName"));
		}
		else
		{
			displayName=(String)myUser.getAttribute("username");
		}
	}
	else
	{
		displayName="";
	}
	if(verbose)
	{
		System.out.println("Done authenticating");
	}
%>
<meta session="authenticated">