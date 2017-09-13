/*
	FileName:DACDriver.h
	Author:GuoCheng
	E-mail:fortune@mail.ustc.edu.cn
	All right reserved @ GuoCheng.
	Modified: 2017.6.30
	Description: Export function.
*/

#pragma once

#ifdef DLLAPI
#else
#define DLLAPI __declspec(dllimport)
#endif

#ifndef WORD
#define WORD unsigned short
#endif

#ifndef UINT
#define UINT unsigned int
#endif

#ifndef LPVOID
#define LPVOID void*
#endif

#ifndef NULL
#define NULL 0
#endif


/* Open a device and add it to device list. */
DLLAPI int Open(UINT */*pID*/,char*/*ip*/,WORD/*port*/);
/* Close the device and clear the data */
DLLAPI int Close(UINT/*id*/);
/* Write a command to FPGA */
DLLAPI int WriteInstruction(UINT/*id*/,UINT/*instructino*/,UINT/*para1*/,UINT/*para2*/);
/* Write data to DDR4 */
DLLAPI int WriteMemory(UINT/*id*/,UINT/*instruction*/,UINT/*start*/,UINT/*length*/,WORD*/*pData*/);
/* Read data from DDR4 */
DLLAPI int ReadMemory(UINT/*id*/,UINT/*instruction*/,UINT/*start*/,UINT/*length*/);
/* Set TCPIP timeout,uint:second. */
DLLAPI int SetTimeOut(UINT/*id*/,UINT /*direction*/,float/*time*/);
/* Get funtion type and parameter */
DLLAPI int GetFunctionType(UINT/*id*/,UINT/*offset*/,UINT*/*pFunctype*/,UINT */*pInstruction*/,UINT */*pPara1*/,UINT */*pPara2*/);
/* If run as PARALLEL mode, the result will be store in stack, The stack is first in last out.*/
DLLAPI int GetReturn(UINT/*id*/,UINT /*offset*/,int*/*pRespStat*/,int*/*pRespData*/,WORD*/*pData*/);
/* Check whether the task execute finished. */
DLLAPI int CheckFinished(UINT/*id*/,UINT* /*isFinished*/);
/* Wait task finished */
DLLAPI int WaitUntilFinished(UINT /*id*/,UINT /*time*/);
/* Get software Information*/
DLLAPI int GetSoftInformation(char */*description*/);
/* Scan the local network */
DLLAPI int ScanDevice(char *);
/* Check if all task successed. */
DLLAPI int CheckSuccessed(UINT/*id*/,UINT */*pIsSuccessed*/,UINT*/*pPosition*/);
/* Get lastest error message */
DLLAPI int GetErrorMsg(int/* errorcode */,char */* strMsg */);