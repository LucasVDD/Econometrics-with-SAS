data usa;                              * open data set;
infile 'C:/Programming/Econometrics-with-SAS/9. Unit Roots/usa.txt';
input gdp inf f b;
run;

/* create lag, difference and date variables */
data usa;                              * open data set;
set usa;                               * read data;
dgdp = dif(gdp);                       * first differences;
dinf = dif(inf);
df = dif(f);
db = dif(b);
retain date '1oct83'd;                 * date variable;
date=intnx('qtr',date,1);              * update dates;
format date yyqc.;                     * format for date;
year = 1984 + int((_n_-1)/4);          * year;
qtr = mod(_n_-1, 4) + 1;               * quarter;
run;

proc print data=usa (obs=5);           
run;

/* plot levels and differences using PROC GPLOT */

symbol1 value=point interpol=join;     * symbol for diagram;
proc gplot data=usa;
plot gdp*date = 1 / hminor=1;
title 'Real gross domestic product (GDP)';	
run;

proc gplot data=usa;
plot dgdp*date = 1 / hminor=1 vref=0;
title 'Change in GDP';
run;

proc gplot data=usa;
plot inf*date = 1 / hminor=1;	
title 'Inflation rate';
run;

proc gplot data=usa;
plot dinf*date = 1 / hminor=1 vref=0;
title 'Change in the inflation rate';
run;

proc gplot data=usa;
plot f*date = 1 / hminor=1;
title 'Federal funds rate';
run;

proc gplot data=usa;
plot df*date = 1 / hminor=1 vref=0;
title 'Change in the Federal funds rate';
run;

proc gplot data=usa;
plot b*date = 1 / hminor=1;	
title 'Three-year bond rate';
run;

proc gplot data=usa;
plot db*date = 1 / hminor=1 vref=0;
title 'Change in the bond rate';
run;

/* obtain summary statistics for two sample periods */
proc means data=usa;                   * summary statistics;
var gdp inf f b dgdp dinf df db;       * variable list;
where dgdp ne . and year <= 1996;      * sample period 1;
title 'summary statistics 1984q2 to 1996q4';
run;

proc means data=usa;                   * summary statistics;
var gdp inf f b dgdp dinf df db;       * variable list;
where year > 1996;                     * sample period 2;
title 'summary statistics 1997q1 to 2009q4';
run;


/* create lags and lagged differences */
data usa;                              * open data set;
set usa;                               * read data;
f1 = lag(f);                           * lag f;
df1 = lag(df);                         * lag df;
b1 = lag(b);                           * lag b;
db1 = lag(db);                         * lag db;
run;

/* unit root tests for Fed funds series */
proc autoreg data=usa;
model df = f1 df1;
title 'augmented Dickey-Fuller test for federal funds rate';
run;

%dftest(usa,f,ar=1,outstat=dfout);     * Dickey-Fuller test;
proc print data=dfout;                 * print results;
title 'Dickey-Fuller test for federal funds rate';
run;

/* unit root tests for 3-year bond rate series */
proc autoreg data=usa;
model db = b1 db1;
title 'augmented Dickey-Fuller test for 3 year bond rate';
run;

%dftest(usa,b,ar=1,outstat=dbout);     * Dickey-Fuller test;
proc print data=dbout;                 * print results;
title 'Dickey-Fuller test for 3 year bond rate';
run;


/* create differences of first differences */
data usa;                              * open data set;
set usa;                               * read data;
ddf = dif(df);                         * difference of df;
ddb = dif(db);                         * difference of db;
run;

proc print data=usa (obs=10);
var f df df1 ddf b db db1 ddb;
run;

/* unit root tests for diffrenced federal fund series */
proc autoreg data=usa;
model ddf = df1 / noint;               * specify no intercept;
title 'Dickey-Fuller test for differenced federal funds series';
run;

%dftest(usa,df,ar=0,trend=0,outstat=ddfout);* Dickey-Fuller test;
proc print data=ddfout;                     * print results;
title 'Dickey-Fuller test for differenced fed funds series';
run;


/* unit root tests for diffrenced 3 year bond rate series */
proc autoreg data=usa;
model ddb = db1 / noint;               * specify no intercept;
title 'Dickey-Fuller test for differenced 3 year bond rate series';
run;

%dftest(usa,db,ar=0,trend=0,outstat=ddbout);* Dickey-Fuller test;
proc print data=ddbout;                     * print results;
title 'Dickey-Fuller test for differenced 3 year bond rate series';
run;


/* regression of 3 year bond rate on fed funds rate */
proc autoreg data=usa;
model b = f;                           * model;
output out=usaout r=ehat;              * save residuals;
title 'save residuals to test for cointegration';
run;

/* create lags and differences */
data usaout;                           * open data set;
set usaout;                            * read data;
dehat = dif(ehat);                     * first difference;
ehat1 = lag(ehat);                     * lag of ehat;
dehat1 = lag(dehat);                   * lag of first difference;
run;

/* Dickey-Fuller regression on residuals: test for cointegration */
proc autoreg data=usaout;
model dehat = ehat1 dehat1 / noint;    * ADF regression;
title 'test for cointegration';
run;