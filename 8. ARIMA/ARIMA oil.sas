options linesize=78;

* to read in the data *;

data oil;
infile 'C:/Programming/Econometrics-with-SAS/8. ARIMA/oil.dat';
input y;


proc arima data=oil;
identify var=y nlag=20;
estimate p=1;
forecast lead=5;
run;


data ar1;
set oil;
ylag1 = lag (y);
ylag2 = lag2 (y);
t=_n_;

proc print data=ar1;
run;

proc reg;
model y = ylag1;

title 'data from oil.dat';

proc gplot data=ar1;
plot y*t;
symbol interpol=join;
run;

proc reg;
model y = ylag1 ylag2;

proc arima;
identify var=y nlag=20;
estimate p=2;
estimate p=2 method=ml;
forecast lead=5;
run;
 
proc arima;
identify var=y nlag=20;
estimate p=5 method=ml;
forecast lead=5;
run;

