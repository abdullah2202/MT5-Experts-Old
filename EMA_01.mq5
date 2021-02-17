#include <Trade/Trade.mqh>


/***
 * 
 * 
 */




/* * * * * * * * * * * * * * * * * * * * *
   Input variables - Accessible from MT5
 * * * * * * * * * * * * * * * * * * * * */
input double lot = 1.0;                            // Lot Size
input int slpip = 30;                              // Stop Loss Pips
input int tppip = 75;                              // Take Profit Pips
input int trailingsl = 25;                         // Trailing SL points


/* * * * * * * * * * * * * * * * * * * * *
 Service Variables - Only Accessible in code
 * * * * * * * * * * * * * * * * * * * * */
CTrade trade;

double candles[3][4];   // Previous 3 candles' OLHC
double bbDataMid[], bbDataLow[], bbDataUp[], macdData[], signalData[], mfiData[];
int numBBMid, numBBLow, numBBUp, numMACD, numSignal, numMFI;
int bbHandle, macdHandle, mfiHandle;
int P;
double currentBid, currentAsk;
double stopLossPipsFinal, takeProfitPipsFinal, stopLevelPips;
double slLevel, tpLevel;
double bbMid1, bbMid2, bbLow1, bbLow2, bbUp1, bbUp2, macd1, macd2, signal1, signal2, mfi1, mfi2;
double trailing_stop_value;

double ema8Data[];
int ema8Handle;
int numEma8;


int OnInit(){
   // Print("Init started");

   int emaHandle = iEMA(_Symbol,PERIOD_CURRENT,8,0,MODE_SMA,PRICE_CLOSE);
   ArraySetAsSeries(ema8Data,true);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
  
}

void OnTick(){
   static datetime timestamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT,0);

   // Run this code once per candles
   if(timestamp != time){
      timestamp = time;



   }

}


void getEMA(){
  
  numEma8 = CopyBuffer(ema8Handle,0,0,3,ema8Data);

  

}
