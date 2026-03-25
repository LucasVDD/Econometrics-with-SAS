options nodate nonumber linesize=7;

data byd;                              * open data set;
infile 'C:/Programming/Econometrics-with-SAS/10. GARCH/byd.txt';
input ret;
run;

data byd;
set byd;                             * read byd;
time = _n_;                            * time variable;
run;

/* summary statistics */
proc means data=byd;
var ret;
title 'summary statistics for BYD returns';
run;

proc univariate data=byd normaltest;
var ret;
histogram ret;
title 'BYD returns';

qqplot ret;
run;


/* plot series using PROC GPLOT */
symbol1 value=point interpol=join;     * symbol for diagram;
proc gplot data=byd;
plot ret*time=1 / hminor=1;
title 'BYD returns';	
run;

/* regress byd returns on constant and save residuals */
proc autoreg data=byd;
model ret = ;                            
output out=bydout r=ehat;
title 'estimate mean of byd returns and save residuals';
run;

/* create squared residual and its lag for ARCH test */
data bydout;                           * open data set;
set bydout;                            * read data;
ehatsq = ehat**2;                      * squared residuals;
ehatsq1 = lag(ehatsq);                 * lagged squared residuals;
run;

/* test for ARCH effects */
proc autoreg data=bydout;
model ehatsq = ehatsq1;                * auxiliary regression;
title 'test for ARCH effects in byd data';
run;


/* estimate ARCH(1) model using PROC AUTOREG */
proc autoreg data=bydout;
model ret = / method=ml archtest
            garch=(q=1);               * ARCH(1) errors;
output out=bydout r=ehat_arch ht=harch;* forecast volatility; 
title 'estimate ARCH(1) model and  fit volatility';
run;

/* plot conditional variances using PROC GPLOT */
proc gplot data=bydout;
plot harch*time=1 / hminor=10;	
title 'plot of conditional variance: ARCH(1) model';
run;

/* estimate GARCH(1,1) model using PROC AUTOREG */
proc autoreg data=bydout;
model ret = / method=ml archtest
            garch=(p=1,q=1);               * GARCH(1,1) errors;
output out=bydout r=ehat_garch ht=hgarch11;* forecast volatility; 
title 'estimate GARCH(1,1) model and fit volatility';
run;

/* plot conditional variances using PROC GPLOT */
proc gplot data=bydout;
plot hgarch11*time=1 / hminor=10;	
title 'plot of conditional variance: GARCH(1,1) model';
run;


/* create bad news indicator variable and interaction term */
data bydout;                           * open data set;
set bydout;                            * read data;
dt = (ehat<0);                   * bad news indicator;
dt1 = lag(dt);                         * lag;
ehat_gsq = (ehat**2);            * squared residual;
ehat_gsq1 = lag(ehat_gsq);             * lag;
desq1 = dt1*(ehat_gsq1);               * variable for TGARCH;
run;

proc print data=bydout (obs=5);
title 'byd data with bad news indicator';
run;

/* estimate T-GARCH(1,1) model using PROC AUTOREG */
proc autoreg data=bydout;
model ret = / method=ml archtest
            garch=(p=1,q=1);           * GARCH(1,1) errors;
output out=bydout ht=htgarch;          * forecast volatility; 
hetero desq1;                          * bad news term;
title 'estimate T-GARCH(1,1) model and fit volatility';
run;

/* plot conditional variances using PROC GPLOT */ 
proc gplot data=bydout;
plot htgarch*time / hminor=10;	
title 'plot of conditional variance: T-GARCH(1,1) model';
run;


/* estimate GARCH-M model with time varying volatility */
proc autoreg data=bydout;
model ret = / method=ml archtest
            garch=(p=1,q=1,mean=linear);* GARCH-M(1,1) errors;   
output out=bydout ht=hgarchm p=preturn;* fit volatility; 
title 'GARCH-M model';
run;

/* plot conditional variance using PROC GPLOT */
proc gplot data=bydout;
plot hgarchm*time=1 / hminor=10;	
title 'plot of conditional variance: GARCH-M';
run;


