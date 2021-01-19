#include <Trade/Trade.mqh>

CTrade trade;
double lot = 1.0;
int slpip = 90;
int tppip = 100;

int OnInit(){

   Print("On Init");

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){

   static datetime timestamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT,0);
   if(timestamp != time){  // Only run this once per candle
      
      // Timestamp is now time
      timestamp = time;
      
      // Init Indicators
      static int SMA_slow = iMA(_Symbol,PERIOD_CURRENT,100,0,MODE_SMA,PRICE_CLOSE);
      static int SMA_fast = iMA(_Symbol,PERIOD_CURRENT,35,0,MODE_SMA,PRICE_CLOSE);
  
      // Indicator Arrays
      double SMA_slow_array[];
      double SMA_fast_array[];
      
      // Copy buffers - From indicator to array
      CopyBuffer(SMA_slow,0,1,2,SMA_slow_array);
      CopyBuffer(SMA_fast,0,1,2,SMA_fast_array);
  
      // Set as series
      ArraySetAsSeries(SMA_slow_array,true);
      ArraySetAsSeries(SMA_fast_array,true);
   
      
      // Bullish Trend
      if(SMA_fast_array[0] > SMA_slow_array[0] && SMA_fast_array[1] < SMA_slow_array[1]){
      
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         double sl = ask - slpip * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         double tp = ask + tppip * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         trade.Buy(lot,_Symbol,ask,sl,tp,"This is a BUY");
      
      }
      
      // Bearish Trend
      if(SMA_fast_array[0] < SMA_slow_array[0] && SMA_fast_array[1] > SMA_slow_array[1]){
         
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         double sl = bid + slpip * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         double tp = bid - tppip * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         trade.Sell(lot,_Symbol,bid,sl,tp,"This is a SELL");
         
      }
      
   }

  
  
}