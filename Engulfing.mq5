#include <Trade/Trade.mqh>


/* * * * * * * * * * * * * * * * * * * * *
   Input variables - Accessible from MT5
 * * * * * * * * * * * * * * * * * * * * */
input double lot = 0.1;                            // Lot Size

double pipValue;

double tppip = 10;
double slpip = 10;
int atr = 14;
int ATRTP = 1;

/* * * * * * * * * * * * * * * * * * * * *
 Service Variables - Only Accessible in code
 * * * * * * * * * * * * * * * * * * * * */
CTrade trade;

double currentBid, currentAsk, currentSpread;
double reqData[], atrReq[];

int numTrades = 0;
int numOpenTrades = 0;
int openPositions = 0;

string engulfResult = "";

int OnInit(){
   // Print("Init started");

   // Check Digits - Get value of one Pip
   pipValue = getPipValue();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
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

    openPositions = PositionsTotal();

    // Run this code once per candle
    if(timestamp != time){
        timestamp = time;

        // Print("Positions: " + (string) PositionsTotal());
        
        //Print("SL: " + (string) calcBSL());
        //Print("ATR: " + (string) getATR());

        engulfResult = checkForEngulfing();
        //Print("Engulf Result: " + engulfResult);

        if(engulfResult == "bearish"){
            //Print("Bearish Engulfing");
            makeTrade("sell");
            numTrades++;
        }
        else if(engulfResult == "bullish"){
            //Print("Bullish Engulfing");
            makeTrade("buy");
            numTrades++;
        }

    }


    // Code to be run on every tick

    // If we have some positions open
    if(openPositions>0){
        for(int i=0;i<openPositions;i++){
            PositionGetSymbol(i);
            long pos_ticket = PositionGetInteger(POSITION_TICKET);
            double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
            

            
        }
    }


}


/*
- - - - - - - - - - - - - - - 
Strategy code below
- - - - - - - - - - - - - - - 
*/

/**
 * Bearish engulfing candle after 4 bullish candles
 */
string checkForEngulfing(){
    double size;
    double atrSize = getATR();

    double candleClose[7];
    double candleOpen[7];
    double candleHigh[7];
    double candleLow[7];
    double candleSize[7];
    int totalCandlesToRead = 4;
    int totalCandles = totalCandlesToRead + 2;

    for(int i=1; i<=totalCandles; i++){
        candleClose[i] = iClose(_Symbol,PERIOD_CURRENT,i);
        candleOpen[i] = iOpen(_Symbol,PERIOD_CURRENT,i);
        candleHigh[i] = iHigh(_Symbol,PERIOD_CURRENT,i);
        candleLow[i] = iLow(_Symbol,PERIOD_CURRENT,i);

        size = candleHigh[i] - candleLow[i];
        if(size<0){
            size = size * -1;
        }

        candleSize[i] = size;
    }

    if(
        candleSize[5] >= atrSize &&
        candleSize[4] >= atrSize &&
        candleSize[3] >= atrSize &&
        candleSize[2] >= atrSize &&
        candleSize[1] >= atrSize
    ){
        if(
        //    candleClose[6]<candleClose[5] && 
            candleClose[5]<candleClose[4] && 
            candleClose[4]<candleClose[3] && 
            candleClose[3]<candleClose[2] && 
            candleClose[1]<candleOpen[2] 
        ){
            return "bearish";
        }else if(
         //   candleClose[6]>candleClose[5] && 
            candleClose[5]>candleClose[4] && 
            candleClose[4]>candleClose[3] && 
            candleClose[3]>candleClose[2] && 
            candleClose[1]>candleOpen[2] 
        ){
            return "bullish";
        }
    }

    return "-";
}

double calcBSL(){
    double sizeOfCandle;
    double atr2 = getATR()*2;
    double sl;
    sizeOfCandle = iHigh(_Symbol, PERIOD_CURRENT, 1) - iLow(_Symbol, PERIOD_CURRENT, 1);
    if(sizeOfCandle>atr2){
        //sl = iClose(_Symbol, PERIOD_CURRENT,1) - (getATR()*1.5);
        sl = iLow(_Symbol, PERIOD_CURRENT, 1);
    }
    else{
        sl = iLow(_Symbol, PERIOD_CURRENT, 1);
    }
    return sl;
}

double calcBTP(){
    double atr2 = getATR()*ATRTP;
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
        sl = iHigh(_Symbol, PERIOD_CURRENT, 1);
    }
    else{
        sl = iHigh(_Symbol, PERIOD_CURRENT, 1);
    }
    return sl;
}

/**
 * Calculate TP for Sells
 */
double calcSTP(){
    double atr2 = getATR()*ATRTP;
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
