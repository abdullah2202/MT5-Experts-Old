#include <Trade/Trade.mqh>


/* * * * * * * * * * * * * * * * * * * * *
   Input variables - Accessible from MT5
 * * * * * * * * * * * * * * * * * * * * */
input double lot = 0.5;                            // Lot Size

double pipValue;

double tppip = 10;
double slpip = 10;
int atr = 14;

/* * * * * * * * * * * * * * * * * * * * *
 Service Variables - Only Accessible in code
 * * * * * * * * * * * * * * * * * * * * */
CTrade trade;

double currentBid, currentAsk, currentSpread;
double reqData[], atrReq[];

int numTrades = 0;
int numOpenTrades = 0;


int OnInit(){
   // Print("Init started");

   // Set As Series
   //ArraySetAsSeries(emaData,true);

   // Init Indicators
   //initIndicators();

   // Check Digits - Get value of one Pip
   pipValue = getPipValue();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   // Releaee Indicators
   releaseIndicators();
   Print("Num Trades: " + (string) numTrades);
}

void OnTick(){
   // Sort out Date and Time
   static datetime timestamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT,0);
   
   // Get current ASK and BID
   currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // Work out current spread
   currentSpread = (currentBid - currentAsk) / pipValue;

   // Copy Buffers
   //copyBuffers();

   // Copy Data

   // Run this code once per candle
   if(timestamp != time){
      timestamp = time;


      // If no trades are open
      if(numOpenTrades<1){

        // Print("Spread: " + (string) currentSpread);
        // Print("EMA:" + (string) emaData[1]);
        // Print(iClose(_Symbol,PERIOD_CURRENT,1));
        
        Print("ATR: " + (string) atr);

        if(checkForBearEngulfing()){
            //Print("Bearish Engulfing");
            numTrades++;
        }
        else if(checkForBullEngulfing()){
            //Print("Bullish Engulfing");
            numTrades++;
        }

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


bool checkForBearEngulfing(){
    double can1, can2, can3, can4, can5, can2o, can6;

    can1 = iClose(_Symbol, PERIOD_CURRENT,1);
    can2 = iClose(_Symbol, PERIOD_CURRENT,2);
    can2o = iOpen(_Symbol, PERIOD_CURRENT,2);
    can3 = iClose(_Symbol, PERIOD_CURRENT,3);
    can4 = iClose(_Symbol, PERIOD_CURRENT,4);
    can5 = iClose(_Symbol, PERIOD_CURRENT,5);
    can6 = iClose(_Symbol, PERIOD_CURRENT,6);

    if(
        can6<can5 &&
        can5<can4 &&
        can4<can3 &&
        can3<can2 &&
        can1<can2o 
    ){
        return true;
    }

    return false;
}

bool checkForBullEngulfing(){
    double can1, can2, can3, can4, can5, can2o, can6;

    can1 = iClose(_Symbol, PERIOD_CURRENT,1);
    can2 = iClose(_Symbol, PERIOD_CURRENT,2);
    can2o = iOpen(_Symbol, PERIOD_CURRENT,2);
    can3 = iClose(_Symbol, PERIOD_CURRENT,3);
    can4 = iClose(_Symbol, PERIOD_CURRENT,4);
    can5 = iClose(_Symbol, PERIOD_CURRENT,5);
    can6 = iClose(_Symbol, PERIOD_CURRENT,6);

    if(
        can5>can4 &&
        can4>can3 &&
        can3>can2 &&
        can1>can2o 
    ){
        return true;
    }

    return false;
}

void calcBSL(){

}

void calcBTP{

}

double getATR(){
    double total = 0.0;
    double result;
    double size;
    for(i=1; i<=atr; i++){
        size = iClose(_Symbol, PERIOD_CURRENT, i) - iOpen(_Symbol, PERIOD_CURRENT, i);
        if(size<0){
            size = size * -1;
        }
        total = total + size;
    }

    return total/atr;
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
}

/**
 * Init Indicators - Called OnInit()
 */
void initIndicators(){
   
}

/**
 * Release Indicators - Called onDeInit()
 */
void releaseIndicators(){
   
}

void copyBuffers(){
   
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
