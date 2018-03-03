#include <stdio.h>
#include <stdlib.h>


unsigned long long loadCounter = 0;

void exitfunc()
{
	printf("%llu Load Instructions\n", loadCounter);
}

void addLoad()
{
	//printf("NUMBER OF LOADS EXECUTED := %llu\n", loadCounter);
	loadCounter++;
}

void setupAtExit() 
{
	atexit(exitfunc);
}
