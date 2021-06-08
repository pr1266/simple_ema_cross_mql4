#define MACROSS_OPEN_BUY_SIGNAL 1
#define MACROSS_OPEN_SELL_SIGNAL -1
#define MACROSS_NO_SIGNAL 0
#define MACROSS_MAGIC_NUM 20130715

// parameter haye Trade :
int Pending = 10;
int Delay = 700;
double Lots = 0.1;
string pairs = "GBPUSD";
int short_emas = 8;
int long_emas = 21;
int StopLoss = 550;
int TakeProfit = 550;

void MaRecentValues(string symbol, double& ma[], int maPeriod, int numValues = 3){
   for(int i=0; i < numValues; i++){
        ma[i] = iMA(symbol, 0, maPeriod, 0, MODE_EMA, PRICE_CLOSE, i);
    }
}

int OpenSignal(int short_ema, int long_ema, string symbol){
    int signal = 0;
    double shortMa[3];
    MaRecentValues(symbol, shortMa, short_ema, 3);
    double longMa[3];
    MaRecentValues(symbol, longMa, long_ema, 3);

    //---- buy conditions
    if(shortMa[1] < longMa[1]
    && shortMa[0] > longMa[0]){
    // inja ye close
        signal = 1;
    }

    //---- sell conditions
    if(shortMa[1] > longMa[1]
    && shortMa[0] < longMa[0]){
        signal = -1;
    }
    // inja shart e mosavi boodan e ema :
    if(shortMa[1] == longMa[1]){
        
        if(shortMa[2] > longMa[2]
        && shortMa[0] < longMa[0]){
            signal = -1;
        }
        
        if(shortMa[2] < longMa[2]
        && shortMa[0] > longMa[0]){
            signal = 1;
        }
    }
   return(signal);
}

int OnInit(){
    EventSetMillisecondTimer(500);
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
    EventKillTimer();
}

void OnTimer(){
    
    int order;
    int timeCount = Period();
    datetime barEnd = Time[0] + (timeCount * 60);
    int SecondsToBarEnd = barEnd - TimeCurrent();
    //Comment(SecondsToBarEnd);

    if(SecondsToBarEnd == 1){        
        int signal = OpenSignal(short_emas, long_emas, pairs);
        if (signal == 1){
            // inja bid o ask e pair ro darar :
            double bid_ = NormalizeDouble(SymbolInfoDouble(pairs, SYMBOL_BID), _Digits);

            // inja order send kon :
            order = OrderSend
            (
                pairs, // symbol
                OP_BUYSTOP, // operation
                Lots, // volume
                bid_ + Pending * Point(),  // price
                0, // slippage
                bid_ - (StopLoss * Point()), // Stop loss price.
                bid_ + (TakeProfit * Point()), // Take profit price.
                StringConcatenate(short_emas, " and ", long_emas, " buy"), // comment
                NULL, // magic number
                TimeCurrent() + Delay, // expiration
                Green // arrow color
            );
        }
                
        else if (signal == -1){
            // inja bid o ask e pair ro darar :
            double ask_ = NormalizeDouble(SymbolInfoDouble(pairs, SYMBOL_ASK), _Digits);
            
            // inja order send kon :
            order = OrderSend
            (
                pairs, // symbol
                OP_SELLSTOP, // operation
                Lots, // volume
                ask_ - Pending * Point(), // price
                0, // slippage
                ask_ + (StopLoss * Point()),  // Stop loss price.
                ask_ - (TakeProfit * Point()), // Take profit price.
                StringConcatenate(short_emas, " and ", long_emas, " sell"), // comment
                NULL, // magic number
                TimeCurrent() + Delay, // expiration
                Red // arrow color
            );
        }
    }
}