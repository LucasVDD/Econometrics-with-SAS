options nodate nonumber linesize=78 label;

data gdp;                              * open data set;
infile 'C:/Programming/Econometrics-with-SAS/12. VEC/gdp.txt';
input aus usa;


/* create lags, differences and time variables */
data gdp;                              * open data set;
set gdp;                               * read data;
dusa = dif(usa);                       * first differences;
daus = dif(aus);
retain date '1oct69'd;                 * date variable;
date=intnx('qtr',date,1);              * update dates;
format date yyqc.;                     * format for date;
year = 1970 + int((_n_-1)/4);          * year;
qtr = mod(_n_-1, 4) + 1;               * quarter;
run;

proc print data=gdp (obs=5);           * summary statistics;
title 'first 5 observations for GDP data';
run;  

****************************************************

/* ECM and VEC MODEL */

****************************************************


/* plot series using PROC GPLOT*/
legend1 label=none
        position=(top center inside)
        mode=share;                    * create legend;
symbol1 value=none interpol=join color=blue width=3;
symbol2 value=none interpol=join color=black width=3 line=20;
proc gplot data=gdp;
plot usa*date=1 aus*date=2 / hminor=1 overlay legend=legend1;	
title 'Real gross domestic products(GDP=100 in 2000)';	
run;

/* plot differenced series using PROC GPLOT */
proc gplot data=gdp;
plot dusa*date=1 daus*date=2 / hminor=1 vref=0 overlay legend=legend1;	
title 'Change in real gross domestic products';	
run;

/* unit root tests for levels */
%dftest(gdp,usa,ar=2,trend=2,outstat=dfusa);     * Dickey-Fuller test;
proc print data=dfusa;
title 'ADF test for real GDP: U.S.';
run;

%dftest(gdp,aus,ar=4,trend=2,outstat=dfaus);     * Dickey-Fuller test;
proc print data=dfaus;
title 'ADF test for real GDP: Australia';
run;

/* unit root test for differences */
%dftest(gdp,dusa,ar=1,trend=1,outstat=dfdusa);   * Dickey-Fuller test;
proc print data=dfdusa;
title 'ADF test for differenced real GDP: U.S.';
run;

%dftest(gdp,daus,ar=2,trend=1,outstat=dfdaus);   * Dickey-Fuller test;
proc print data=dfdaus;
title 'ADF test for difference real GDP: Australia';
run;

/* regression of AUS on USA: Long run cointegrating relation */
proc autoreg data=gdp;
model aus = usa / noint;                         
output out=gdpout r=ehat;              * output residuals;
title 'regress Australian GDP on U.S. GDP';
run;

/* create lag and difference of residuals */
data gdpout;                           * open data set;
set gdpout;                            * read data;
dehat = dif(ehat);                     * first difference;
ehat1 = lag(ehat);                     * lag of ehat;
run;

/* test for cointegration */
proc autoreg data=gdpout;
model dehat = ehat1 / noint;           * ADF regression;
title 'test for cointegration';
run;

/* Estimation of ECM valid if r.h.s variables equal */

/* estimate ECM model */
proc autoreg data=gdpout;
model daus = ehat1;
title 'estimate response in Australia to a cointegrating error';
run;

proc autoreg data=gdpout;
model dusa = ehat1;
title 'estimated response in U.S. to a cointegrating error';
run;

/* Estimation of VEC model and impulse responses */

ods graphics on;
proc varmax data=gdpout lagmax=4 dftest;
model aus usa / p=2;
cointeg rank=1 normalize=aus;

title 'estimated VEC model';
run;
ods graphics off;  




