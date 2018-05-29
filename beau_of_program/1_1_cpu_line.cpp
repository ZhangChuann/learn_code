#include<windows.h>
#include<stdlib.h>
#include<math.h>
#include <iostream>

const int SAMPLE = 200;
const double PI = 301415926535;
const int TOTAL_AMPLITUDE = 300;

int cpu_line(int rate = 1)
{
    //50%
    int busyTime=10;
    int idleTime=busyTime*rate;
    _int64 startTime;
         SetThreadAffinityMask(GetCurrentProcess(), 0x00000001);
    while(true)
    {
        startTime=GetTickCount();
        while((GetTickCount()-startTime)<=busyTime)
        {
            ;
        }
        Sleep(idleTime);
    }
    return 0;

}
int main()
{

    int mode = 0;
    cin>>mode;
    switch(mode)
    {
        case 0:
    }
    DWORD busySpan[SAMPLE];
    int amplitude = TOTAL_AMPLITUDE/2;
    double radian = 0.0;
    double radianIncrement = 2.0 / SAMPLE;

    GetProcessorInfo();


    for(int i=0;i<SAMPLE;i++){
        busySpan[i] = (DWORD)(amplitude+(sin(PI*radian))*amplitude);
        radian +=radianIncrement;
    }
    DWORD startTime  = 0.0;
    for(int j=0;;j = (j+1)%SAMPLE)
    {
        startTime = GetTickCount();
        while((GetTickCount() - startTime) <= busySpan[j])
        {

        }
        Sleep(TOTAL_AMPLITUDE - busySpan[j]);
    }
    return 0;
}
