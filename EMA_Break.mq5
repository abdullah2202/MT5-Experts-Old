#include <Trade/Trade.mqh>


/* * * * * * * * * * * * * * * * * * * * *
   Input variables - Accessible from MT5
 * * * * * * * * * * * * * * * * * * * * */
input double lot = 0.5;                            // Lot Size

double pipValue;

double tppip = 10;
double slpip = 10;

/* * * * * * * * * * * * * * * * * * * * *
 Service Variables - Only Accessible in code
 * * * * * * * * * * * * * * * * * * * * */
CTrade trade;

double currentBid, currentAsk, currentSpread;
double emaData[], difference[], differenceSD[];
int emaHandle;
int numEma;
int numTrades = 0;
int numOpenTrades = 0;


int OnInit(){
   // Print("Init started");

   // Set As Series
   ArraySetAsSeries(emaData,true);

   // Init Indicators
   initIndicators();

   // Check Digits - Get value of one Pip
   pipValue = getPipValue();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   // Releaee Indicators
   releaseIndicators();
}

void OnTick(){
   // Sort out Date and Time
   static datetime timestamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT,0);
   string maCrossover = "none";

   // Get current ASK and BID
   currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // Work out current spread
   currentSpread = (currentBid - currentAsk) / pipValue;

   // Copy Buffers
   copyBuffers();

   // Copy Data

   // Run this code once per candle
   if(timestamp != time){
      timestamp = time;


      // If no trades are open
      if(numOpenTrades<1){

         Print("Spread: " + (string) currentSpread);
         Print("EMA:" + (string) emaData[1]);
         Print(iClose(_Symbol,PERIOD_CURRENT,1));

      }
      else{
         // If Trades are open
         // Check if exit rules match

      }
      


      

     


   }
}

/*
- - - - - - - - - - - - - - - 
Strategy code below
- - - - - - - - - - - - - - - 
*/

string checkEMABreak(){
   return "";
}


/**
 * 1) get difference between last 2 digits of ema
 * 2) add this difference to array
 * 3) If number flips from + to - then Bearish and - to + is bullish
 * 4) check SD, if increase then strong movement and vice versa
 * 5) run end of each 1min candle
 */


string getGradient(){
   /**
    * 1) get last value for ema
    * 2) add value to end of array
    * 3) if number of values >0 check difference => getDifference()
    * 4) add difference to array
    * 5) return 1 of 5 values depending on previous 2 difference values
    *    - - => Bearish
    *    + - => New Bearish
    *    + + => Bullish
    *    - + => New Bullish
    *    0 0 => No Change
    * 6) work out standard deviation of difference values 
    */
   return "";
}

/**
 * returns difference between first and second doubles
 */
double getDifference(double first, double second){
   double result = first - second;
   return result;
}



/*
- - - - - - - - - - - - - - - 
Non Strategy code below
- - - - - - - - - - - - - - - 
*/

/**
 * Set all arrays as series
 */
void setArrayAsSeries(){
   ArraySetAsSeries(emaData,true);
}

/**
 * Init Indicators - Called OnInit()
 */
void initIndicators(){
   emaHandle = iMA(_Symbol,PERIOD_CURRENT,25,0,MODE_EMA,PRICE_CLOSE);
}

/**
 * Release Indicators - Called onDeInit()
 */
void releaseIndicators(){
   IndicatorRelease(emaHandle);
}

void copyBuffers(){
   numEma = CopyBuffer(emaHandle,0,0,11,emaData); 
}

/**
 * Gets value of one pip. 
 * This is multipled by the SL/TP 
 * and added to price
 */
double getPipValue(){
   int digits = _Digits;
   if(digits >= 4){
      return 0.0001;
   }
   else{
      return 0.01;
   }
}

void makeTrade(string type){

   if(type=="buy"){
      double slLevel = currentAsk - (slpip * pipValue);
      double tpLevel = currentAsk + (slpip * pipValue);
      trade.PositionOpen(_Symbol, ORDER_TYPE_BUY,lot,currentAsk,slLevel,tpLevel, "Buy Trade. Magic Number: " + (string) trade.RequestMagic());

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
      double slLevel = currentBid + (slpip * pipValue);
      double tpLevel = currentBid - (tppip * pipValue);
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
