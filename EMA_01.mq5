#include <Trade/Trade.mqh>


/* * * * * * * * * * * * * * * * * * * * *
   Input variables - Accessible from MT5
 * * * * * * * * * * * * * * * * * * * * */
input double lot = 1.0;                            // Lot Size
input int slpip = 30;                              // Stop Loss Pips
input int tppip = 75;                              // Take Profit Pips
input int trailingsl = 25;                         // Trailing SL points

double pipValue;

/* * * * * * * * * * * * * * * * * * * * *
 Service Variables - Only Accessible in code
 * * * * * * * * * * * * * * * * * * * * */
CTrade trade;


double ema6Data[], sma12Data[];
int ema6Handle, sma12Handle;
int numEma6, numSma12;


int OnInit(){
   // Print("Init started");

   // Set As Series
   ArraySetAsSeries(ema6Data,true);

   // Init Indicators
   initIndicators();

   // Check Digits - Get calue of one Pip
   pipValue = getPipValue();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   // Releaee Indicators
   releaseIndicators();
}

void OnTick(){
   static datetime timestamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT,0);

   // Copy Buffers
   copyBuffers();

   // Copy Data

   // Run this code once per candles
   if(timestamp != time){
      timestamp = time;

      //Print("- - - - - - - - - - - - - -");
      checkMACrossover();
      //Print("- - - - - - - - - - - - - -");
   }
}

/*
- - - - - - - - - - - - - - - 
Strategy code below
- - - - - - - - - - - - - - - 
*/

// TODO
// Test EMA arrays as print
// Return 1/2 dpending on which is above at what point
void checkMACrossover(){
//   Print(ArraySize(ema6Data));
if(ArraySize(ema6Data)>5 && ArraySize(sma12Data)>5){
   string calc0 = calcFastOverSlow(ema6Data[0],sma12Data[0]);
   string calc1 = calcFastOverSlow(ema6Data[1],sma12Data[1]);
   
   if(calc0=="bear" && calc1=="bull"){
      Print("- - - - - - - - ");
      Print("SELL SIGNAL");
      Print("- - - - - - - - ");
   }

   if(calc0=="bull" && calc1=="bear"){
      Print("- - - - - - - - ");
      Print("BUY SIGNAL");
      Print("- - - - - - - - ");
   }
   
}
}

// Check Gradients - flat=consolidation
void checkGradientEma6(){}
void checkGradientSma12(){}

// Check MACD
void checkMACDStatus(){}




string calcFastOverSlow(double fast, double slow){
   if(fast>slow){
      return "bull";
   }
   else{
      return "bear";
   }
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
   ArraySetAsSeries(ema6Data,true);
   ArraySetAsSeries(sma12Data,true);
}

/**
 * Init Indicators - Called OnInit()
 */
void initIndicators(){
   ema6Handle = iMA(_Symbol,PERIOD_CURRENT,6,0,MODE_EMA,PRICE_CLOSE);
   sma12Handle = iMA(_Symbol,PERIOD_CURRENT,12,0,MODE_SMA,PRICE_CLOSE);
}

/**
 * Release Indicators - Called onDeInit()
 */
void releaseIndicators(){
   IndicatorRelease(ema6Handle);
   IndicatorRelease(sma12Handle);
}

void copyBuffers(){
   numEma6 = CopyBuffer(ema6Handle,0,0,11,ema6Data); 
   numSma12 = CopyBuffer(sma12Handle,0,0,11,sma12Data);
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
