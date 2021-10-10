#include <Trade/Trade.mqh>


/* * * * * * * * * * * * * * * * * * * * *
   Input variables - Accessible from MT5
 * * * * * * * * * * * * * * * * * * * * */
input double lot = 0.1;                            // Lot Size

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
        
        
        //Print("SL: " + (string) calcBSL());
        //Print("ATR: " + (string) getATR());

        if(checkForBearEngulfing()){
            //Print("Bearish Engulfing");
            makeTrade("sell");
            numTrades++;
        }
        else if(checkForBullEngulfing()){
            //Print("Bullish Engulfing");
            makeTrade("buy");
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
        can6>can5 &&
        can5>can4 &&
        can4>can3 &&
        can3>can2 &&
        can1>can2o 
    ){
        return true;
    }

    return false;
}

double calcBSL(){
    double sizeOfCandle;
    double atr2 = getATR()*2;
    double sl;
    sizeOfCandle = iHigh(_Symbol, PERIOD_CURRENT, 1) - iLow(_Symbol, PERIOD_CURRENT, 1);
    if(sizeOfCandle>atr2){
        //sl = iClose(_Symbol, PERIOD_CURRENT,1) - (getATR()*1.5);
        sl = iLow(_Symbol, PERIOD_CURRENT, 1) - getATR();
    }
    else{
        sl = iLow(_Symbol, PERIOD_CURRENT, 1) - getATR();
    }
    return sl;
}

double calcBTP(){
    double atr2 = getATR()*2;
    double tp;
    tp = iHigh(_Symbol, PERIOD_CURRENT, 1) + atr2;
    return tp;
}

double calcSSL(){
    double sizeOfCandle;
    double atr2 = getATR()*2;
    double sl;
    sizeOfCandle = iHigh(_Symbol, PERIOD_CURRENT, 1) - iLow(_Symbol, PERIOD_CURRENT, 1);
    if(sizeOfCandle>atr2){
        //sl = iClose(_Symbol, PERIOD_CURRENT, 1) + (getATR()*1.5);
        sl = iLow(_Symbol, PERIOD_CURRENT, 1) + getATR();
    }
    else{
        sl = iLow(_Symbol, PERIOD_CURRENT, 1) + getATR();
    }
    return sl;
}

/**
 * Calculate TP for Sells
 */
double calcSTP(){
    double atr2 = getATR()*2;
    double tp;
    tp = iLow(_Symbol, PERIOD_CURRENT, 1) - atr2;
    return tp;
}

double getATR(){
    double total = 0.0;
    double result = 0.0;
    double size;
    for(int i=1; i<=atr; i++){
        size = iLow(_Symbol, PERIOD_CURRENT, i) - iHigh(_Symbol, PERIOD_CURRENT, i);
        if(size<0){
            size = size * -1;
        }
        total = total + size;
    }

    result = total / atr;
    //result = result / pipValue;
    result = NormalizeDouble(result, 3);
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
      double slLevel = calcBSL();
      double tpLevel = calcBTP();
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
      double slLevel = calcSSL();
      double tpLevel = calcSTP();
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
