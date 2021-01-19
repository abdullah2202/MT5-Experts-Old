#include <Trade/Trade.mqh>

CTrade trade;
double lot = 1.0;
int slpip = 30;
int tppip = 80;
int slow_ma = 100;
int fast_ma = 20;
int rsi_upper = 65;
int rsi_lower = 35;

int OnInit(){return(INIT_SUCCEEDED);}
void OnDeinit(const int reason){}

void OnTick(){

   static datetime timestamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT,0);
   int positions = PositionsTotal();
   
   if(timestamp != time){
     // Print("Positions:" + IntegerToString(positions));
      
      // Timestamp is now time
      timestamp = time;
      
      // Init Indicators
      static int SMA_slow = iMA(_Symbol,PERIOD_CURRENT,slow_ma,0,MODE_EMA,PRICE_CLOSE);
      static int SMA_fast = iMA(_Symbol,PERIOD_CURRENT,fast_ma,0,MODE_EMA,PRICE_CLOSE);
      static int RSI = iRSI(_Symbol,PERIOD_CURRENT,14,PRICE_CLOSE);
  
      // Indicator Arrays
      double SMA_slow_array[];
      double SMA_fast_array[];
      double RSI_array[];
      
      // Copy buffers - From indicator to array
      CopyBuffer(SMA_slow,0,1,2,SMA_slow_array);
      CopyBuffer(SMA_fast,0,1,2,SMA_fast_array);
      CopyBuffer(RSI,0,1,2,RSI_array);
  
      // Set as series
      ArraySetAsSeries(SMA_slow_array,true);
      ArraySetAsSeries(SMA_fast_array,true);
      ArraySetAsSeries(RSI_array,true);
   
      Print(RSI_array[0]);
      // Bullish Trend
      if(
         SMA_fast_array[0] > SMA_slow_array[0] && 
         SMA_fast_array[1] < SMA_slow_array[1] 
        //&& RSI_array[1] > rsi_upper
         ){
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         double sl = ask - slpip * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         double tp = ask + tppip * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         trade.Buy(lot,_Symbol,ask,sl,tp,"This is a BUY");
      }
      
      // Bearish Trend
      else if(
         SMA_fast_array[0] < SMA_slow_array[0] && 
         SMA_fast_array[1] > SMA_slow_array[1] 
         //&& RSI_array[1] < rsi_lower
         ){
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         double sl = bid + slpip * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         double tp = bid - tppip * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
        // trade.Sell(lot,_Symbol,bid,sl,tp,"This is a SELL");
         
      }
      
   }

  
  
}