options linesize=78;

* read in the data *;

data tesla;
infile 'C:/Programming/Econometrics-with-SAS/1. AR(p)/TESLA.txt';
input price;
return = dif(log(price));
t=_n_;

* print the data *;

proc print data=tesla (obs=10);
run;

* calculate the statistics *;

proc univariate normal plot;
var return;
probplot;

run; 

* plot the prices *;

title 'daily prices of TESLA 2019/01/02 - 2021/12/31';
 
proc gplot;

plot price*t;

symbol interpol=joint;

run;


* plot the returns *;

title 'daily returns on TESLA 2019/01/02 - 2021/12/31';

proc gplot;

plot return*t;

symbol interpol=joint;

run;




* estimate the AR(1) model *;

proc autoreg;

model return =/nlag = 1;

run;

* added a section to see phi of prices to answer questions 1-3 *;


proc autoreg;

model price =/nlag = 1;

run;