#include<Trade\Trade.mqh>
CTrade trade;

double FunModiSlSell(double Bid, double TSlInicial, double SlAtual, double Price0a0, double Spreed, double Tp);
double FunModiSlBuy(double Ask, double TSlInicial, double SlAtual, double Price0a0, double Spreed, double Tp);

int Fun_Martelo(int Periodo, double &lows[], double &highs[], double &closes[], double &opens[]);
int Fun_Estrela(int Periodo, double &lows[], double &highs[], double &closes[], double &opens[]);

int  Fun_Total_Posicoes();
int Fun_Pontos();

double Fun_Calc_Lote_C(double Ask, double StopInicialC, double pBalance);
double Fun_Calc_Lote_V(double Bid, double StopInicialV, double pBalance);

bool FunPontoRetornoC(double &closes[], double &highs[], double &bufferz[]);
bool FunPontoRetornoV(double &closes[], double &lows[], double &bufferz[]);

int zigzag=iCustom(NULL, PERIOD_CURRENT, "Examples\\ZigZag",12,6,12);
void OnTick()
   {
      double highs[];            // DECLARAÇÃO DE VARIAVEIS E LISTAS DE INFORMAÇÃO DE PREÇOS \\       [C]
      double lows[];
      double closes[];
      double opens[];
      datetime datas[];
      double Ask;
      double Bid;
      int Periodo = 12;     // PERIODO PARA DETERMINAR A ONDA\\
      
      ArraySetAsSeries(highs,true);                      // COPIANDO PREÇOS \\         [C]
      CopyHigh(_Symbol,_Period,0,Bars(_Symbol,PERIOD_CURRENT),highs);
      ArraySetAsSeries(lows,true);
      CopyLow(_Symbol,_Period,0,Bars(_Symbol,PERIOD_CURRENT),lows);
      ArraySetAsSeries(closes,true);
      CopyClose(_Symbol,_Period,0,Bars(_Symbol,PERIOD_CURRENT),closes);
      ArraySetAsSeries(opens,true);
      CopyOpen(_Symbol,_Period,0,Bars(_Symbol,PERIOD_CURRENT),opens);
      ArraySetAsSeries(datas,true);
      CopyTime(_Symbol,_Period,0,Bars(_Symbol,PERIOD_CURRENT),datas);      
      Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      //indicador zigzag\\
      double bufferz[];
      ArraySetAsSeries(bufferz,true);
      CopyBuffer(zigzag,0,0,Bars(Symbol(),PERIOD_CURRENT),bufferz);
   }

//+--------------------------------------------------------------------------------------------------------------------------------+
//|                                                       V A R I A D A S                                                          |
//+--------------------------------------------------------------------------------------------------------------------------------+
int  Fun_Total_Posicoes()
   {
      int PosSymTotal = 0;
      for(int i=0; i<PositionsTotal(); i++)
         {
            if(PositionGetSymbol(i)==Symbol())
               {
                  PosSymTotal = PosSymTotal + 1;
               }
         }
      return(PosSymTotal);
   }
   
//                            *                                   *
int Fun_Pontos()
   {  
      int TransformePontos;
      if(_Digits == 5)
         {
            TransformePontos = 100000;
         }
      else
         {
            if(_Digits == 4)
               {
                  TransformePontos = 10000;
               }
            else
               {
                  if(_Digits == 3)
                     {
                        TransformePontos = 1000;
                     }
                  else
                     {
                        if(_Digits == 2)
                           {
                              TransformePontos = 100;
                           }
                        else
                           {
                              return(-1);
                           }
                     }
               }
         }
      return(TransformePontos);
   }
//+--------------------------------------------------------------------------------------------------------------------------------+
//|                                                    M O V E R   S T O P                                                         |
//+--------------------------------------------------------------------------------------------------------------------------------+
double FunModiSlSell(double Bid, double TSlInicial, double SlAtual, double Price0a0, double Spreed, double Tp)
   {
      while (Bid < SlAtual - 2 * TSlInicial - Spreed  && SlAtual > Price0a0)
         {
            PositionSelect(_Symbol);
            trade.PositionModify(PositionGetTicket(0),SlAtual - 2 * Point(), Tp);
            SlAtual = SlAtual - 2 * Point();
         }
      return(SlAtual);
   }

double FunModiSlBuy(double Ask, double TSlInicial, double SlAtual, double Price0a0, double Spreed, double Tp)
   {
      while (Ask > SlAtual + 2 * TSlInicial + Spreed  &&  SlAtual < Price0a0)
         {
            PositionSelect(_Symbol);
            trade.PositionModify(PositionGetTicket(0),SlAtual + 2 * Point(), Tp);
            SlAtual = SlAtual + 2 * Point();
         }
      return(SlAtual);
   }

//+---------------------------------------------------------------------------------------------- --------------------------------+
//|                                                 P A D R O E S   C A N D L E S                                                 |
//+-------------------------------------------------------------------------------------------- ----------------------------------+
int Fun_Martelo(int Periodo, double &lows[], double &highs[], double &closes[], double &opens[])
   {
   
      double corpo;
      double calda;
      double chifre;
      double candle1;
      double calda2;
      int a = 0;
      
      
      if(closes[1] >= opens[1])
         {
            corpo = closes[1] - opens[1];
            calda = opens[1] - lows[1];
            chifre = highs[1] - closes[1];
         }
      else
         {
            corpo = opens[1] - closes[1];
            calda = closes[1] - lows[1];
            chifre = highs[1] - opens[1];
         }
      if((calda > 3 * corpo  &&  chifre < corpo)  ||  (chifre > corpo  &&  calda > 6 * chifre))
         {
            candle1 = highs[1] - lows[1];  // CALCULANDO TAMANHO DO CANDLE 1 \\
            if(closes[2] >= opens[2])        // CALCULADO TAMANDO DA CAUDA DO CANDLE 2 \\
               {
                  calda2 = opens[2] - lows[2];
               }
            else
               {
                  calda2 = closes[2] - lows[2];
               }
            
            while(a < Periodo)
               {
                  if(lows[2] <= lows[1]  &&  calda2 <= candle1)  // SE O CANDLE 2 FOR MENOR QUE O 1 E A CALDA DO 2 NAO FOR MAIOR QUE O CANDLE 1\\
                     {
                        if(lows[a+3] < lows[2])    // SE NAO FOR O MENOR DO PERIODO \\
                           {
                              return(0);
                           }
                     }
                  if(lows[2] > lows[1])    // SE O CANDLE 1 FOR MENOR QUE O 2 \\
                     {
                        if(lows[a+2] < lows[1])    // SE NAO FOR O MENOR DO PERIODO \\
                           {
                              return(0);
                           }
                     }
                  a++;
               }            
            return(1);     // SE FOR O MENOR DO PERIODO \\
         }
      return(0);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Fun_Estrela(int Periodo, double &lows[], double &highs[], double &closes[], double &opens[])
   {
      double corpo;
      double calda;
      double chifre;
      double candle1;
      double chifre2;
      int a = 0;
      
      if(closes[1] >= opens[1])
         {
            corpo = closes[1] - opens[1];
            calda = opens[1] - lows[1];
            chifre = highs[1] - closes[1];
         }
      else
         {
            corpo = opens[1] - closes[1];
            calda = closes[1] - lows[1];
            chifre = highs[1] - opens[1];
         }
      if((chifre > 3 * corpo  &&  calda < corpo)  ||  (calda > corpo  &&  chifre > 6 * calda))
         {
            candle1 = highs[1] - lows[1];  // CALCULANDO TAMANHO DO CANDLE 1 \\
            
            if(closes[2] >= opens[2])        // CALCULADO TAMANDO DA CHIFRE DO CANDLE 2 \\
               {
                  chifre2 = highs[2] - closes[2];
               }
            else
               {
                  chifre2 = highs[2] - opens[2];
               }
               
            while(a < Periodo)
               {
                  if(highs[2] >= highs[1]  &&  chifre2 <= candle1)  // SE O CANDLE 2 MAIOR QUE O 1 E O CHIFRE DO 2 NAO FOR MAIOR QUE O CANDLE 1\\
                     {
                        if(highs[a+3] > highs[2])    // SE NAO FOR O MAIOR DO PERIODO \\
                           {
                              return(0);
                           }
                     }
                  if(highs[2] < highs[1])    // SE O CANDLE 1 FOR MAIOR QUE O 2 \\
                     {
                        if(highs[a+2] > highs[1])    // SE NAO FOR O MAIOR DO PERIODO \\
                           {
                              return(0);
                           }
                     }
                  a++;
               }
            return(1);     // SE FOR O MAIOR DO PERIODO \\
         }
      return(0);
   }
//+------------------------------------------------------------------------------------------------------------------------------------+
//|                                    F U N Ç Õ E S   P A R A   C A L C U L A R   O   L O T E                                         |
//+------------------------------------------------------------------------------------------------------------------------------------+
double Fun_Calc_Lote_V(double Bid, double StopInicialV, double pBalance)
   {
      string LoteSt;
      double LotePadrao;
      if(((StopInicialV - Bid) * Fun_Pontos()) != 0)
         {
            LotePadrao = pBalance/((StopInicialV - Bid) * Fun_Pontos());
            LoteSt = DoubleToString(LotePadrao,2);
            LotePadrao = StringToDouble(LoteSt);
         }
      else
         {
            return(-1);
         }
      //Print("volume: ",LotePadrao);
      return(LotePadrao);
   }
   
//                            *                                   *
double Fun_Calc_Lote_C(double Ask, double StopInicialC, double pBalance)
   {
      string LoteSt;
      double LotePadrao;
      if(((Ask - StopInicialC) * Fun_Pontos()) != 0)
         {
            LotePadrao = pBalance/((Ask - StopInicialC) * Fun_Pontos());
            LoteSt = DoubleToString(LotePadrao,2);
            LotePadrao = StringToDouble(LoteSt);
         }
      else
         {
            return(-1);
         }
      //Print("volume: ",LotePadrao);
      return(LotePadrao);
   }
//+--------------------------------------------------------------------------------------------------------------------------------+
//|                                              P o n t o s   d e   r e t o r n o                                                 |
//+--------------------------------------------------------------------------------------------------------------------------------+
bool DirecaoOnda(double &bufferz[])
   {
      bool engrenagem = true;
      int p0,p1;
      for(int i=0; i<ArraySize(bufferz); i++){
         if(engrenagem==true){
            if(bufferz[i]!=0){
               p0=i;
               engrenagem=false;
            }
         }
         else{
            if(bufferz[i]!=0 &&  bufferz[i]!=bufferz[p0]){
               p1=i;
               break;
            }
         }
      }
      if(bufferz[p0]>bufferz[p1]){
         return(true);
      }
      return(false);
   }

bool FunPontoRetornoV(double &closes[], double &lows[], double &bufferz[])
   {
      int p0=0;
      if(DirecaoOnda(bufferz)==true){
         for(int i=0; i<ArraySize(bufferz);i++){
            if(bufferz[i]!=0){
               p0=i;
               break;
            }
         }
         if(closes[1]<lows[p0] && bufferz[0]==0){
            for(int i=2;i<p0;i++){
               if(closes[i]<lows[p0]){
                  return(false);
               }
            }
            return(true);
         }
      }
      return(false);
   }
bool FunPontoRetornoC(double &closes[], double &highs[], double &bufferz[])
   {
      int p0=0;
      if(DirecaoOnda(bufferz)==false){
         for(int i=0; i<ArraySize(bufferz);i++){
            if(bufferz[i]!=0){
               p0=i;
               break;
            }
         }
         if(closes[1]>highs[p0] && bufferz[0]==0){
            for(int i=2;i<p0;i++){
               if(closes[i]>highs[p0]){
                  return(false);
               }
            }
            return(true);
         }
      }
      return(false);
   }
//+--------------------------------------------------------------------------------------------------------------------------------+
//|                                              P o n t o s   d e   r e t o r n o                                                 |
//+--------------------------------------------------------------------------------------------------------------------------------+