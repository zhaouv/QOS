#ifndef ADCDRIVER_H
#define ADCDRIVER_H

#ifdef DLLAPI
#else
#define DLLAPI __declspec(dllimport)
#endif

#define OK 0
#define ERR_NODATA 1
#define ERR_NONETCARD 2
#define ERR_WINPCAP 3
#define ERR_CHANNEL 4
#define ERR_HANDLE 5
#define ERR_OTHER 100

/* 打开ADC设备，需要提供目的ADC的MAC地址，协议类型，网卡的设备号 */
DLLAPI int OpenADC(int num);
/* 关闭ADC设备 */
DLLAPI int CloseADC();
/* 往ADC写入数据 */
DLLAPI int SendData(int len,unsigned char*pData);
/* 从ADC读回数据 */
DLLAPI int RecvData(int len,int column, unsigned char*pDataI, unsigned char *pDataQ);
/* 从ADC读回解模数据 */
DLLAPI int RecvDemo(int row,int* pData);
/* 返回网卡列表 */
DLLAPI int GetAdapterList(char*list);
/* 返回错误信息 */
DLLAPI int GetErrorMsg(int errorcode,char *strMsg);
/* 获取版本信息 */
DLLAPI int GetSoftInformation(char *pInformation);
#endif