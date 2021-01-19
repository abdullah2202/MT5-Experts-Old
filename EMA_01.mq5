#include <Trade/Trade.mqh>

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


int OnInit(){
   setArraysAsSeries();    // Set data arrays as series
   initIndicators();       // Init indicators
   checkBrokerDigits();    // To account for brokers that use 5 digits
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   releaseIndicators();    // Release indicators
}

void OnTick(){
   static datetime timestamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT,0);
   
   // Get current price data
   currentAsk = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   currentBid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   
   copyBuffers();
   copyData();
   //calculateSLTPPips(); // Gave errors, took too long to debug
   
   // Update candle array with previous candle data - OHLC
   candles[0][1] = iHigh(_Symbol,PERIOD_CURRENT,1);   // Previous High
   candles[0][2] = iLow(_Symbol,PERIOD_CURRENT,1);    // Previous Low
   candles[0][3] = iClose(_Symbol,PERIOD_CURRENT,1);  // Previous Close
   candles[1][3] = iClose(_Symbol,PERIOD_CURRENT,2);  // Previous-1 Close
   
   // Only run this code once a candle
   if(timestamp != time){
      timestamp = time;
      
      // Get calculated stats for indicators
      int bb = getBB();
      int macd = getMACD();
      int mfi = getMFI();
      
      //---- Exit Trade Rules
      if(PositionSelect(_Symbol) == true){
   
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      Print("--------Free Margin: ",freeMargin);
   
      //-- Exit Long Trade
   
      //-- Exit Short Trade
   
      }
   
      //---- Enter Trade Rules
      if(PositionSelect(_Symbol) == false){
   
         //-- Enter Long Trade
         if(bb==1 
            && macd==1 
           // && mfi==1
           ){
            makeTrade("buy");
         }
   
         //-- Enter Short Trade
         if(bb==2 
            && macd==2 
          //  && mfi==1
          ){
            makeTrade("sell");
         }
      }
      
   }
   
   // Trailing stop loss
   if(trailingsl>0 && PositionSelect(_Symbol)==true){
      ENUM_POSITION_TYPE positionType = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double localSL;
      double tlStop = (double) trailingsl * _Point * P;
   
      if(positionType==POSITION_TYPE_BUY){
         if(currentBid-openPrice>tlStop){
            localSL = NormalizeDouble(currentBid-tlStop,Digits());
            if(currentSL<localSL){
               trade.PositionModify(_Symbol,localSL,tpLevel);
               if(trade.ResultRetcode()==10008 || trade.ResultRetcode()==10009){
                  // Success
               }
               else{
                  Print("-------Stop Loss updating failed. Error: ", GetLastError());
                  ResetLastError();
                  return;
               }
            }
         }
      }
      else if(positionType==POSITION_TYPE_SELL){
         if(openPrice-currentAsk>tlStop){
            localSL = NormalizeDouble(currentAsk+tlStop,Digits());
            if(currentSL>localSL){
               trade.PositionModify(_Symbol,localSL,tpLevel);
               if(trade.ResultRetcode()==10008 || trade.ResultRetcode()==10009){
                  // Success
               }
               else{
                  Print("-------Stop Loss updating failed. Error: ", GetLastError());
                  ResetLastError();
                  return;
               }
            }
         }
      }
   }
}


void makeTrade(string type){

   if(type=="buy"){
      slLevel = currentAsk - (slpip * _Point * P);
      tpLevel = currentAsk + (tppip * _Point * P);
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lot,currentAsk,slLevel,tpLevel,"Buy Trade. Magic Number: " + (string) trade.RequestMagic());
      
      if(trade.ResultRetcode()==10008 || trade.ResultRetcode()==10009){
         Print("Entry Rules: Buy order successfully placed with Ticket#: " + (string) trade.ResultOrder());
      }
      else{
         Print("Entry Rules: Buy order could not be completed. Error: ", GetLastError());
         ResetLastError();
         return;
      }
   }
   if(type=="sell"){
      slLevel = currentBid + (slpip * _Point * P);
      tpLevel = currentBid - (tppip * _Point * P);
      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lot,currentBid,slLevel,tpLevel,"Sell Trade. Magic Number: " + (string) trade.RequestMagic());
   
      if(trade.ResultRetcode()==10008 || trade.ResultRetcode()==10009){
         Print("Entry Rules: Sell order successfully placed with Ticket#: " + (string) trade.ResultOrder());
      }
      else{
         Print("Entry Rules: Sell order could not be completed: Error: ", GetLastError());
         ResetLastError();
         return;
      }
   }
}

/**
   Set Data arrays as series - Called in init()
 **/
void setArraysAsSeries(){
   ArraySetAsSeries(bbDataMid,true);
   ArraySetAsSeries(bbDataLow,true);
   ArraySetAsSeries(bbDataUp,true);
   ArraySetAsSeries(macdData,true);
   ArraySetAsSeries(signalData,true);
   ArraySetAsSeries(mfiData,true);
}

/**
   Initialise Indicators
   - Called in OnInit()
 **/
void initIndicators(){
   bbHandle = iBands(_Symbol,PERIOD_CURRENT,bb_averaging,bb_shift,bb_sd,PRICE_CLOSE);
   macdHandle = iMACD(_Symbol,macd_timeframe,macd_fast,macd_slow,macd_signal,PRICE_CLOSE);
   mfiHandle = iMFI(_Symbol,mfi_timeframe,mfi_period,VOLUME_TICK);
}

/**
   Release Indicators
   - Called in OnDeInit()
 **/
void releaseIndicators(){
   IndicatorRelease(bbHandle);
   IndicatorRelease(macdHandle);
   IndicatorRelease(mfiHandle);
}

/**
   Copy buffers for indicators
   - Called in OnTick()
 **/
void copyBuffers(){
   numBBMid = CopyBuffer(bbHandle,0,0,3,bbDataMid);
   numBBUp = CopyBuffer(bbHandle,1,0,3,bbDataUp);
   numBBLow = CopyBuffer(bbHandle,2,0,3,bbDataLow);
   numMACD = CopyBuffer(macdHandle,0,0,3,macdData);
   numSignal = CopyBuffer(macdHandle,1,0,3,signalData);
   numMFI = CopyBuffer(mfiHandle,0,0,3,mfiData);
}

/**
   Copy data from Indicators for previous and previous-1 candles.
   - Called in OnTick()
 **/
void copyData(){
   bbMid1 = bbDataMid[1];
   bbMid2 = bbDataMid[2];
   bbLow1 = bbDataLow[1];
   bbLow2 = bbDataLow[2];
   bbUp1 = bbDataUp[1];
   bbUp2 = bbDataUp[2];
   macd1 = macdData[1];
   macd2 = macdData[2];
   signal1 = signalData[1];
   signal2 = signalData[2];
   mfi1 = mfiData[1];
   mfi2 = mfiData[2];
}

/**
   Calculate SL & TP pips adjusted with Spreads
 **/
void calculateSLTPPips(){
   stopLevelPips = (double) (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) + SymbolInfoInteger(_Symbol, SYMBOL_SPREAD)) * P;
   if(slpip < stopLevelPips){
      stopLossPipsFinal = stopLevelPips;
   }
   else{
      stopLossPipsFinal = slpip;
   }
   if(tppip < stopLevelPips){
      takeProfitPipsFinal = stopLevelPips;
   }
   else{
      takeProfitPipsFinal = tppip;
   }
}

/**
   Check Broker Digits
   - Called in OnInit()
 **/
void checkBrokerDigits(){
   if(_Digits==5 || _Digits==3 || _Digits==1)P = 10;else P = 1;
}

/**
   Get Bollinger Band Values.
 **/
int getBB(){
   double prevClose = candles[0,3];
   double prevClose2 = candles[1,3];
   double prevHigh = candles[0,1];
   double prevLow = candles[0,2];
   
   // If BB has some data, greater than 0;
   if(bbMid1>0){
      if(prevHigh>bbUp1 && prevClose2<bbUp2){
         return 1; // Bullish
      }
      else if(prevLow<bbLow1 && prevClose2>bbLow2){
         return 2; // Bearish
      }
   }
   return 0;
}


int getMACD(int test=0){
   if(macd1>0 && macd1>signal1 && macd1>macd2){
      return 1;   // Bullish
   }
   else if(macd1<0 && macd1<signal1 && macd1<macd2){
      return 2;   // Bearish
   }
   else{
      return 0;   // No Change
   }
}


int getMFI(){
   if(mfi1>75 || mfi1<30){
      return 0;   // Don't trade
   }
   else{
      return 1;   // OK to trade
   }
}