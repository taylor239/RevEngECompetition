package com.data;

import java.io.Serializable;

public class ImageDataHolder implements Serializable
{
	private byte[] myData;
	private String myName;
	public ImageDataHolder(byte[] data, String name)
	{
		myData=data;
		myName=name;
	}
	public byte[] getData()
	{
		return myData;
	}
	public String getName()
	{
		return myName;
	}
}
