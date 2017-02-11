package com.data;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.Scanner;
import java.util.regex.Pattern;

public class CallgrindInterpreter
{

	public static void main(String[] args)
	{
		File myFile = new File(args[0]);
		//File outputFile = new File(args[1]);
		PrintWriter outputWriter = null;
		try
		{
			outputWriter = new PrintWriter(args[1]);
		}
		catch (FileNotFoundException e1)
		{
			e1.printStackTrace();
		}
		
		String content = "";
		try
		{
			content = new Scanner(myFile).useDelimiter("\\Z").next();
			//content = "\"" + content + "\"";
		}
		catch (FileNotFoundException e)
		{
			e.printStackTrace();
		}
		
		//System.out.println(content);
		
		args = new String[1];
		args[0] = content;
		
		//System.out.println(args.length);
		if(args.length==1)
		{
			String stringToParse = args[0];
			ArrayList finalArgs = new ArrayList();
			String tmp = "";
			boolean inQuotes = false;
			for(int x=0; x<stringToParse.length(); x++)
			{
				if(stringToParse.charAt(x) == ' ' && inQuotes == false)
				{
					//System.out.println(tmp);
					//if(!tmp.isEmpty())
					{
						//System.out.println("Next arg");
						//System.out.println(tmp);
						finalArgs.add(tmp);
						tmp = "";
					}
				}
				else if(stringToParse.charAt(x) == '"')
				{
					inQuotes = !inQuotes;
				}
				else
				{
					tmp = tmp + stringToParse.charAt(x);
				}
			}
			//System.out.println("Next arg");
			//System.out.println(tmp);
			//finalArgs.add(tmp);
			//if(true)
			//{
			//	return;
			//}
			String[] newArgs = new String[finalArgs.size()];
			for(int y=0; y<finalArgs.size(); y++)
			{
				newArgs[y] = (String) finalArgs.get(y);
			}
			args = newArgs;
		}
		//System.out.println(args.length);
		for(int x=0; x<args.length; x++)
		{
			//System.out.println("Argument " + x);
			//System.out.println(args[x]);
		}
		HashMap resultsMap = new HashMap();
		for(int x=0; x<args.length; x+=4)
		{
			//System.out.println("New Arg");
			String id = args[x];
			String program = args[x+1];
			String arguments = args[x+2];
			String inputString = args[x+3];
			if(inputString.isEmpty() || inputString.equals(""))
			{
				continue;
			}
			//System.out.println(x);
			//System.out.println(id);
			//System.out.println(program);
			//System.out.println(arguments);
			//System.out.println(inputString);
			HashMap idResults;
			if(resultsMap.containsKey(id))
			{
				idResults = (HashMap) resultsMap.get(id);
			}
			else
			{
				idResults = new HashMap();
			}
			HashMap argResults;
			if(idResults.containsKey(arguments))
			{
				argResults = (HashMap) idResults.get(arguments);
			}
			else
			{
				argResults = new HashMap();
			}
			
			HashMap output = processString(inputString);
			//System.out.println(output);
			argResults.put(program, output);
			idResults.put(arguments, argResults);
			resultsMap.put(id, idResults);
		}
		
		HashMap successMap = new HashMap();
		HashMap failMap = new HashMap();
		//System.out.println(resultsMap);
		Iterator resultsIter = resultsMap.entrySet().iterator();
		while(resultsIter.hasNext())
		{
			Entry resultsPair = (Entry) resultsIter.next();
			String id = (String) resultsPair.getKey();
			//System.out.println(id);
			HashMap idMap = (HashMap) resultsPair.getValue();
			//System.out.println(idMap);
			Iterator idIter = idMap.entrySet().iterator();
			
			boolean allArgsUniform = true;
			
			while(idIter.hasNext())
			{
				Entry idPair = (Entry) idIter.next();
				String arguments = (String) idPair.getKey();
				HashMap argMap = (HashMap) idPair.getValue();
				//System.out.println(arguments);
				//System.out.println(argMap);
				Iterator argIter = argMap.entrySet().iterator();
				
				boolean allUniform = true;
				boolean allFirst = true;
				ArrayList typeList = new ArrayList();
				ArrayList possibleAddList = new ArrayList();
				
				while(argIter.hasNext())
				{
					Entry argPair = (Entry) argIter.next();
					String run = (String) argPair.getKey();
					HashMap runMap = (HashMap) argPair.getValue();
					//System.out.println(run);
					//System.out.println(threadMap);
					Iterator threadIter = runMap.entrySet().iterator();
					boolean uniform = true;
					boolean first = true;
					ArrayList lastValue = new ArrayList();
					ArrayList threadTypes = new ArrayList();
					ArrayList tentativeAddList = new ArrayList();
					while(threadIter.hasNext())
					{
						Entry threadPair = (Entry) threadIter.next();
						//System.out.println(threadPair.getKey());
						threadTypes.add(threadPair.getKey());
						HashMap threadMap = (HashMap) threadPair.getValue();
						//System.out.println(threadPair.getKey());
						//System.out.println(runMap);
						if(first)
						{
							lastValue = (ArrayList) threadMap.get("output");
							first = false;
						}
						if(!threadMap.get("output").equals(lastValue))
						{
							uniform = false;
						}
						if(uniform)
						{
							//tentativeAddList.add(threadMap);
						}
						//System.out.println(lastValue);
						//System.out.println(threadMap.get("output"));
					}
					//System.out.println(typeList);
					//System.out.println(threadTypes);
					if(allFirst)
					{
						allFirst = false;
						typeList = threadTypes;
					}
					if(!typeList.equals(threadTypes))
					{
						allUniform = false;
					}
					else
					{
						allUniform = uniform;
					}
					if(allUniform)
					{
						//possibleAddList.add(tentativeAddList);
					}
				}
				
				allArgsUniform = allUniform;
			}
			
			if(allArgsUniform)
			{
				successMap.put(resultsPair.getKey(), resultsPair.getValue());
			}
			else
			{
				failMap.put(resultsPair.getKey(), resultsPair.getValue());
			}
		}
		
		Iterator successIter = successMap.entrySet().iterator();
		HashMap successStatistics = new HashMap();
		while(successIter.hasNext())
		{
			Entry successEntry = (Entry) successIter.next();
			HashMap argMap = (HashMap) successEntry.getValue();
			//System.out.println(successEntry.getKey());
			//System.out.println(successEntry.getValue());
			Iterator argIter = argMap.entrySet().iterator();
			while(argIter.hasNext())
			{
				Entry argEntry = (Entry) argIter.next();
				HashMap runMap = (HashMap) argEntry.getValue();
				//System.out.println(argEntry.getKey());
				Iterator runIterator = runMap.entrySet().iterator();
				HashMap prevMap = new HashMap();
				HashMap diffMap = new HashMap();
				while(runIterator.hasNext())
				{
					Entry runEntry = (Entry) runIterator.next();
					//System.out.println(runEntry.getKey());
					HashMap threadMap = (HashMap) runEntry.getValue();
					threadMap = getAverageThreadMap(threadMap);
					//System.out.println(threadMap);
					
					Iterator prevIterator = prevMap.entrySet().iterator();
					while(prevIterator.hasNext())
					{
						Entry prevEntry = (Entry) prevIterator.next();
						HashMap mapToDiff = (HashMap) prevEntry.getValue();
						HashMap diff1 = difference(mapToDiff, threadMap);
						HashMap diff2 = difference(threadMap, mapToDiff);
						diffMap.put(prevEntry.getKey().toString()+runEntry.getKey().toString(), diff1);
						diffMap.put(runEntry.getKey().toString()+prevEntry.getKey().toString(), diff2);
					}
					
					prevMap.put(runEntry.getKey(), threadMap);
				}
				//System.out.println(prevMap);
				//System.out.println(diffMap);
				Iterator prevIter = prevMap.entrySet().iterator();
				while(prevIter.hasNext())
				{
					Entry prevEntry = (Entry) prevIter.next();
					String prevKey = (String) prevEntry.getKey();
					ArrayList successList;
					if(successStatistics.containsKey(prevKey))
					{
						successList = (ArrayList) successStatistics.get(prevKey);
					}
					else
					{
						successList = new ArrayList();
					}
					
					successList.add(prevEntry.getValue());
					
					successStatistics.put(prevKey, successList);
				}
				Iterator diffIter = diffMap.entrySet().iterator();
				while(diffIter.hasNext())
				{
					Entry diffEntry = (Entry) diffIter.next();
					String diffKey = (String) diffEntry.getKey();
					ArrayList successList;
					if(successStatistics.containsKey(diffKey))
					{
						successList = (ArrayList) successStatistics.get(diffKey);
					}
					else
					{
						successList = new ArrayList();
					}
					
					successList.add(diffEntry.getValue());
					
					successStatistics.put(diffKey, successList);
				}
			}
		}
		//System.out.println(successStatistics);
		//System.out.println(successStatistics.keySet());
		HashMap finalMap = new HashMap();
		Iterator finalIterator = successStatistics.entrySet().iterator();
		while(finalIterator.hasNext())
		{
			Entry finalNext = (Entry) finalIterator.next();
			ArrayList tmpList = (ArrayList) finalNext.getValue();
			finalMap.put(finalNext.getKey(), getStatisticsMap(tmpList));
		}
		Iterator finalMapIterator = finalMap.entrySet().iterator();
		//System.out.println(finalMap);
		ArrayList headingList = new ArrayList();
		headingList.add("Run Type");
		ArrayList mapList = new ArrayList();
		boolean firstRun = true;
		while(finalMapIterator.hasNext())
		{
			Entry finalMapEntry = (Entry) finalMapIterator.next();
			//outputWriter.println(finalMapEntry.getKey());
			HashMap finalMapRun = (HashMap) finalMapEntry.getValue();
			if(firstRun)
			{
				firstRun = false;
				Iterator finalMapRunIterator = finalMapRun.entrySet().iterator();
				while(finalMapRunIterator.hasNext())
				{
					Entry finalMapRunEntry = (Entry) finalMapRunIterator.next();
					//System.out.println("\t"+finalMapRunEntry.getKey());
					//System.out.println("\t\t"+finalMapRunEntry.getValue());
					mapList.add(finalMapRunEntry.getKey());
					headingList.add(finalMapRunEntry.getKey()+" Median");
					headingList.add(finalMapRunEntry.getKey()+" Mean");
					headingList.add(finalMapRunEntry.getKey()+" Variance");
					headingList.add(finalMapRunEntry.getKey()+" Std Dev");
				}
				//System.out.println();
				for(int z=0; z<headingList.size(); z++)
				{
					outputWriter.print(headingList.get(z));
					if(z+1<headingList.size())
					{
						outputWriter.print(",");
					}
				}
				outputWriter.println();
			}
			
			{
				outputWriter.print(finalMapEntry.getKey()+",");
				for(int z=0; z<mapList.size(); z++)
				{
					HashMap tmpMap = (HashMap) finalMapRun.get(mapList.get(z));
					outputWriter.print(tmpMap.get("median")+","+tmpMap.get("mean")+","+tmpMap.get("variance")+","+tmpMap.get("stdDev"));
					if(z+1<mapList.size())
					{
						outputWriter.print(",");
					}
				}
				outputWriter.println();
			}
		}
		outputWriter.flush();
		outputWriter.close();
	}
	
	private static HashMap difference(HashMap map1, HashMap map2)
	{
		HashMap myReturn = new HashMap();
		
		Iterator map1Iter = map1.entrySet().iterator();
		while(map1Iter.hasNext())
		{
			Entry map1Entry = (Entry) map1Iter.next();
			String key = (String) map1Entry.getKey();
			double map1Val = (double) map1Entry.getValue();
			double map2Val = (double) map2.get(key);
			myReturn.put(key, map1Val-map2Val);
		}
		
		return myReturn;
	}
	
	private static HashMap getStatisticsMap(ArrayList argList)
	{
		//System.out.println(argList);
		HashMap myReturn = new HashMap();
		
		HashMap typeLists = new HashMap();
		
		for(int x=0; x<argList.size(); x++)
		{
			HashMap curMap = (HashMap) argList.get(x);
			Iterator curIterator = curMap.entrySet().iterator();
			while(curIterator.hasNext())
			{
				Entry curNext = (Entry) curIterator.next();
				ArrayList curList;
				if(typeLists.containsKey(curNext.getKey()))
				{
					curList = (ArrayList) typeLists.get(curNext.getKey());
				}
				else
				{
					curList = new ArrayList();
				}
				curList.add(curNext.getValue());
				typeLists.put(curNext.getKey(), curList);
			}
		}
		//System.out.println(typeLists);
		
		Iterator typeIterator = typeLists.entrySet().iterator();
		while(typeIterator.hasNext())
		{
			Entry typeEntry = (Entry) typeIterator.next();
			ArrayList tmpList = (ArrayList) typeEntry.getValue();
			double[] arrayVal = new double[tmpList.size()];
			for(int x=0; x<tmpList.size(); x++)
			{
				arrayVal[x] = (double) tmpList.get(x);
			}
			Statistics tmpStatistics = new Statistics(arrayVal);
			HashMap statsMap = new HashMap();
			statsMap.put("mean", tmpStatistics.getMean());
			statsMap.put("median", tmpStatistics.getMedian());
			statsMap.put("stdDev", tmpStatistics.getStdDev());
			statsMap.put("variance", tmpStatistics.getVariance());
			myReturn.put(typeEntry.getKey(), statsMap);
		}
		
		return myReturn;
	}
	
	private static HashMap getAverageThreadMap(HashMap runMap)
	{
		HashMap myReturn = new HashMap();
		
		HashMap outputLists = new HashMap();
		
		Iterator threadIterator = runMap.entrySet().iterator();
		while(threadIterator.hasNext())
		{
			Entry threadEntry = (Entry) threadIterator.next();
			HashMap threadMap = (HashMap) threadEntry.getValue();
			//System.out.println(threadEntry.getKey());
			//System.out.println(threadMap);
			ArrayList metrics = (ArrayList) threadMap.get("metrics");
			for(int x=0; x<metrics.size(); x++)
			{
				String metricType = (String) metrics.get(x);
				
				ArrayList outputList;
				if(outputLists.containsKey(metricType))
				{
					outputList = (ArrayList) outputLists.get(metricType);
				}
				else
				{
					outputList = new ArrayList();
				}
				
				//System.out.println(threadMap.get(metricType).getClass());
				outputList.add(new Double((String)threadMap.get(metricType)));
				
				outputLists.put(metricType, outputList);
			}
		}
		//System.out.println(outputLists);
		Iterator outputIter = outputLists.entrySet().iterator();
		while(outputIter.hasNext())
		{
			Entry outputEntry = (Entry) outputIter.next();
			ArrayList outputValue = (ArrayList) outputEntry.getValue();
			double average = averageDouble(outputValue);
			//System.out.println(outputEntry.getKey());
			//System.out.println(average);
			myReturn.put(outputEntry.getKey(), average);
		}
		
		return myReturn;
	}
	
	private static Double averageDouble(ArrayList argList)
	{
		//System.out.println(argList);
		double average = 0;
		
		for(int x=0; x<argList.size(); x++)
		{
			average += (Double)argList.get(x);
		}
		average = average/(double) argList.size();
		//System.out.println(average);
		return average;
	}
	
	/**
	 * 
	 * @param inputString
	 */
	public static HashMap processString(String inputString)
	{
		//System.out.println(inputString);
		if(inputString == null || inputString.isEmpty())
		{
			return null;
		}
		BufferedReader myReader = new BufferedReader(new StringReader(inputString));
		boolean fireJailed=false;
		int lineNum = 0;
		int childProcess = -1;
		int parentProcess = -1;
		ArrayList threadNumbers = new ArrayList();
		HashMap threadOutputMap = new HashMap();
		
		try
		{
			String curLine = myReader.readLine();
			while(curLine != null)
			{
				//System.out.println(lineNum + ": " + curLine);
				Scanner callgrindScanner = new Scanner(curLine).useDelimiter(Pattern.quote(" "));
				Pattern callgrindBegin = Pattern.compile(Pattern.quote("==") + "\\d+" + Pattern.quote("=="));
				Pattern callgrindBeginDots = Pattern.compile(Pattern.quote("--") + "\\d+" + Pattern.quote("--"));
				if(curLine.contains("Reading profile"))
				{
					fireJailed=true;
				}
				else if(curLine.contains("Parent pid"))
				{
					curLine = curLine.replaceAll(Pattern.quote(","), "");
					//System.out.println(lineNum + ": " + curLine);
					Scanner intScanner = new Scanner(curLine).useDelimiter(Pattern.quote(" "));
					while(!intScanner.hasNextInt())
					{
						//System.out.println(intScanner.next());
						intScanner.next();
					}
					parentProcess = intScanner.nextInt();
					while(!intScanner.hasNextInt())
					{
						//System.out.println(intScanner.next());
						intScanner.next();
					}
					childProcess = intScanner.nextInt();
					//System.out.println(parentProcess+ ", "+ childProcess);
				}
				else if(callgrindScanner.hasNext(callgrindBegin))
				{
					String beginString = callgrindScanner.next(callgrindBegin);
					beginString = beginString.replaceAll(Pattern.quote("=="), "");
					if(!threadNumbers.contains(beginString))
					{
						threadNumbers.add(beginString);
					}
					HashMap curMap;
					if(threadOutputMap.containsKey(beginString))
					{
						curMap = (HashMap) threadOutputMap.get(beginString);
					}
					else
					{
						curMap = new HashMap();
						curMap.put("metrics", new ArrayList());
					}
					//System.out.println(beginString);
					
					callgrindScanner.useDelimiter("\n");
					String remainingLine = "";
					if(callgrindScanner.hasNext())
					{
						remainingLine = callgrindScanner.next();
						remainingLine = remainingLine.substring(1, remainingLine.length());
					}
					//System.out.println("Remaining: "+remainingLine);
					
					if(remainingLine.contains("For interactive control, run 'callgrind_control -h'"))
					{
						//System.out.println("Reading output from program");
						ArrayList outputLines = new ArrayList();
						String outputLine = myReader.readLine();
						while(!outputLine.contains("==" + beginString + "=="))
						{
							//System.out.println(outputLine);
							outputLines.add(outputLine);
							outputLine = myReader.readLine();
						}
						curMap.put("output", outputLines);
						//System.out.println("No more output");
					}
					else if(remainingLine.contains("Events    :"))
					{
						remainingLine = remainingLine.substring(12);
						String valueLine = myReader.readLine().substring(18);
						//System.out.println(remainingLine);
						//System.out.println(valueLine);
						Scanner simpleScan1 = new Scanner(remainingLine).useDelimiter(" ");
						Scanner simpleScan2 = new Scanner(valueLine).useDelimiter(" ");
						while(simpleScan1.hasNext())
						{
							String tmp = simpleScan1.next();
							curMap.put(tmp, simpleScan2.next());
							((ArrayList) curMap.get("metrics")).add(tmp);
						}
						//System.out.println(curMap);
					}
					else if(remainingLine.length() > 1)
					{
						Pattern basicValuePattern = Pattern.compile("[\\w\\s]+");
						Pattern basicValuePattern2 = Pattern.compile("\\s*[\\d,.%]+\\s*");
						Pattern basicValuePattern3 = Pattern.compile("\\s*[\\d,.%]+[\\s(]*\\s*[\\d,.%(]+[rd\\s+]*\\s*[\\d,.%]+\\s*[wr)\\s]*");
						Scanner remainingScan = new Scanner(remainingLine).useDelimiter(":");
						//System.out.println(remainingScan.next());
						if(remainingScan.hasNext(basicValuePattern))
						{
							//System.out.println(remainingScan.next(basicValuePattern));
							String varName = remainingScan.next(basicValuePattern);
							if(remainingScan.hasNext(basicValuePattern2))
							{
								//System.out.println(remainingScan.next(basicValuePattern2));
								String varVal = remainingScan.next(basicValuePattern2);
								varVal = varVal.replace(" ", "");
								varVal = varVal.replace("%", "").replace(",", "");
								//System.out.println(varVal);
								curMap.put(varName, varVal);
								((ArrayList) curMap.get("metrics")).add(varName);
							}
							else if(remainingScan.hasNext(basicValuePattern3))
							{
								//System.out.println(remainingScan.next(basicValuePattern3));
								Scanner innerScanner = new Scanner(remainingScan.next(basicValuePattern3));
								Pattern innerPattern = Pattern.compile("[(]*[\\d,.%]+");
								String curState = "total";
								while(innerScanner.hasNext())
								{
									if(innerScanner.hasNext(innerPattern))
									{
										//System.out.println(innerScanner.next(innerPattern));
										String nextVal = innerScanner.next(innerPattern);
										nextVal = nextVal.replace("(", "").replace(" ", "").replace("%", "").replace(",", "");
										//System.out.println(varName + ":" + curState);
										//System.out.println(nextVal);
										curMap.put(varName + ":" + curState, nextVal);
										((ArrayList) curMap.get("metrics")).add(varName + ":" + curState);
										
										if(curState.equals("total"))
										{
											curState = "read";
										}
										else
										{
											curState = "write";
										}
									}
									else
									{
										innerScanner.next();
										//System.out.println(innerScanner.next());
									}
								}
							}
						}
					}
					
					//System.out.println(curMap);
					threadOutputMap.put(beginString, curMap);
				}
				else if(callgrindScanner.hasNext(callgrindBeginDots))
				{
					String beginString = callgrindScanner.next(callgrindBeginDots);
					beginString = beginString.replaceAll(Pattern.quote("--"), "");
					if(!threadNumbers.contains(beginString))
					{
						threadNumbers.add(beginString);
					}
				}
				
				
				
				curLine = myReader.readLine();
				lineNum++;
			}
			
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
		
		return threadOutputMap;
	}

}
