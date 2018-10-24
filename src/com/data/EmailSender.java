package com.data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailSender implements Runnable
{
	private static ConcurrentHashMap senderMap= new ConcurrentHashMap();
	
	public static EmailSender getEmailSender(String email)
	{
		if(!senderMap.containsKey(email))
		{
			senderMap.put(email, new EmailSender(email));
		}
		return (EmailSender) senderMap.get(email);
	}
	
	private Thread workThread;
	private String myEmail, myPassword, host = "localhost";
	private ConcurrentLinkedQueue sendQueue = new ConcurrentLinkedQueue();
	private boolean running = false;
	private Properties properties = System.getProperties();
	private Session session;
	
	private EmailSender(String email)
	{
		properties.setProperty("mail.smtp.host", host);
		myEmail = email;
		session = Session.getDefaultInstance(properties);
		running = true;
		workThread = new Thread(this);
		workThread.start();
	}
	
	/* Testing
	public static void main(String[] args)
	{
		EmailSender mySender = EmailSender.getEmailSender("revenge@cs.arizona.edu");
		mySender.sendEmail("cgtboy1988@yahoo.com", "Test subject", "Test message");
		try
		{
			Thread.currentThread().sleep(11000);
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		mySender.stop();
	}
	*/
	
	public void sendEmail(String recipient, String subject, String message)
	{
		message = message.replace("\n", "<br />");
		HashMap toSend = new HashMap();
		toSend.put("recipient", recipient);
		toSend.put("subject", subject);
		toSend.put("message", message);
		sendQueue.add(toSend);
	}
	
	public void stop()
	{
		running = false;
		try
		{
			workThread.join();
		}
		catch(InterruptedException e)
		{
			e.printStackTrace();
		}
	}

	@Override
	public void run()
	{
		while(running)
		{
			try
			{
				while(sendQueue.size() > 0)
				{
					HashMap curSend = (HashMap) sendQueue.poll();
					System.out.println("Sending message to " + curSend.get("recipient"));
					MimeMessage message = new MimeMessage(session);
					message.setFrom(new InternetAddress(myEmail));
					message.addRecipient(Message.RecipientType.TO, new InternetAddress(((String)curSend.get("recipient"))));
					message.setSubject((String)curSend.get("subject"));
					message.setText((String)curSend.get("message"), "utf-8", "html");
					Transport.send(message);
				}
				workThread.sleep(10000);
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
		}
	}
}
