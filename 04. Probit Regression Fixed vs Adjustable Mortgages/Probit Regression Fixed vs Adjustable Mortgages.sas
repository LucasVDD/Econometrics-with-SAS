options center label nodate nonumber linesize=78;

data mortgage;
infile 'C:/Programming/Econometrics-with-SAS/5. Probit Regression Fixed vs Adjustable Mortgages/sirmans.txt';
input adjust fixrate margin yield maturity points networth;

proc means data=mortgage;
title 'summary stats mortgage data';
run;

/* linear probability model  */
proc reg data=mortgage;
model adjust=fixrate margin yield maturity points networth/clb hcc hccmethod=1;	* using robust se; 	
title 'linear probability model with robust se';
output out=lpmout p=p; 				* output predicted prob;
run;

proc print data=lpmout; 			* print predicted;
title 'predictions linear probability model';
run;


/*  probit  */
proc qlim data=mortgage;			* proc qlim;
model adjust=fixrate margin yield maturity points networth/discrete; * discrete for probit;
output out=probitout xbeta; 	* output;
title 'probit';
run;


/*  predicted values  */
data mortgage2;
set probitout;
p_adjust = probnorm(xbeta_adjust); 		* evaluate estimated prob;
phat = (p_adjust >= .5); 				* phat = 1 if p >= .5;
run;


proc print data=mortgage2;  * print predicted proba and outcomes phat= 0,1;
title 'probit predictions';
run;

proc print data=mortgage2; * sum up variable predicted phay=0-1;
sum phat;
run;

proc means data=mortgage2; * find the mean of phat;
var phat;
run;

/* marginal effect of MARG at means */

data compute;
input mfix mmarg myield mmat mpoint mnet;
xbeta= -1.87 +0.499*mfix -0.431*mmarg -2.384*myield-0.0591*mmat-0.3*mpoint +0.0838*mnet;
pdf=exp(-xbeta**2/2)/sqrt(8*atan(1)); * pdf of standard normal;
mef = -0.431*pdf;   * marg. effect = coeff * pdf;
cards;
13.25 2.292 1.606 1.058 1.498 3.504
proc print;
var mef;
title 'marginal effect of increase in margin at the mean values';
run;


proc qlim data=mortgage;
model adjust=fixrate margin yield maturity points networth/discrete; 
test yield=0, networth=0 / lr;
title 'probit LR test of two coefficients jointly equal to 0';	
run;
