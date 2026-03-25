options nodate nonumber linesize=78 label;

data fred;
infile 'C:/Programming/Econometrics-with-SAS/11. VAR/growth.txt';
input y c;


/* VAR MODEL: create differences and time variables */
data fred;                             * open data set;
set fred;                              * read data;
dc = dif(c);                           * first differences;
dy = dif(y);
retain date '1oct59'd;                 * date variable;
date=intnx('qtr',date,1);              * update dates;
format date yyqc.;                     * format for date;
year = 1960 + int((_n_-1)/4);          * year;
qtr = mod(_n_-1, 4) + 1;               * quarter;
run;

/* plot series using PROC GPLOT */
proc gplot data=fred;
plot y*date=1 c*date=2 / hminor=1 overlay legend=legend1;	
title 'Real personal disposable income and consumption expenditure';	
run;

proc gplot data=fred;
plot dy*date=1 dc*date=2 / hminor=1 vref=0 overlay legend=legend1;
title 'Differences in real income and consumption expenditure';
run;

/* unit root tests for consumption and disposable income series */
%dftest(fred,c,ar=3,trend=1,outstat=dfc);   * Dickey-Fuller test;
proc print data=dfc;
title 'ADF test for consumption with 3 lags';
run;

%dftest(fred,y,ar=0,trend=1,outstat=dfy);   * Dickey-Fuller test;
proc print data=dfy;
title 'ADF test for disposable income with 0 lags';
run;

/* unit root tests for differenced consumption and income series */
%dftest(fred,dc,ar=3,trend=1,outstat=dfdc); * Dickey-Fuller test;
proc print data=dfdc;
title 'ADF test for differenced consumption with 3 lags';
run;

%dftest(fred,dy,ar=3,trend=1,outstat=dfdy); * Dickey-Fuller test;
proc print data=dfdy;
title 'ADF test for differenced disposable income with 3 lags';
run;

/* estimate regression to test for cointegration */
proc autoreg data=fred;
model c = y;                           
output out=fredout r=ehat;
title 'estimate cointegrating relationship: C = B1+B2Y+e';
run;

/* create differenced and lagged residuals */
data fredout;                          * open data set;
set fredout;                           * read data;
dehat = dif(ehat);                     * first difference;
ehat1 = lag(ehat);                     * lag of ehat;
dehat1 = lag(dehat);                   * lagged difference;
run;

/* test for cointergration */
proc autoreg data=fredout;
model dehat = ehat1 dehat1 / noint;    * ADF regression;
title 'Engle-Granger test for cointegration';
run;

/* lag the first difference of each series */
data fredout;                          * open data set;
set fredout;                           * read data;
dc1 = lag(dc);                         * lag first difference;
dy1 = lag(dy);
run;

/* Estimation of VAR  valid only if the r.h.s variables are equal */ 

/* estimate VAR(1) model using PROC AUTOREG */
proc autoreg data=fredout;
model dc = dc1 dy1;
title 'VAR regression for personal consumption expenditure';
run;

proc autoreg data=fredout;
model dy = dc1 dy1;
title 'VAR regression for real personal disposable income';
run;

/* Estimation of VAR */

/* estimate VAR and generate impulse response using PROC VARMAX */
ods graphics on;                       * must turn ODS on;
proc varmax data=fredout plot=impulse;
model dc dy / p=1;
output lead=6;
title 'estimate VAR model and generate impulse response';
run;
ods graphics off;                      * must turn ODS off;


