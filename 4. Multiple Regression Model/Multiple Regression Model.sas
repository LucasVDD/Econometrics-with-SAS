data oecd;
infile "C:/Programming/Econometrics-with-SAS/4. Consumption Growth Regression/Japan.txt" dsd missover dlm="09"X;
input cons gov hours inc ln_y_c r;
ods graphics off;
run;

proc print data =oecd;
var cons gov hours inc r;
run;

proc reg data=oecd;
model cons= hours gov r inc;
title "Regular estimation";
run;

* restricted estimation with beta_2=berta_3=0;

proc reg data=oecd;
model cons= hours gov r inc;
restrict hours=0, gov=0;
title "Restricted estimation beta 2 = beta 3 = 0";
run;

* test beta_2=berta_3=0;

proc reg data=oecd;
model cons= hours gov r inc;
test hours=0, gov=0;
title "test beta 2 = beta 3";
run;

* is there collinearity?;

proc reg data=oecd;
model cons= hours gov r inc/vif;
title "Collinearity/vif";
run;

proc corr data=oecd;
var hours gov r inc;
run;

* condition index;

proc reg data=oecd;
model cons= hours gov r inc/collin;
title "Condition Index";
run;

* without gov;

proc reg data=oecd;
model cons= hours r inc;
title "Without gov";
run;

* gov regressed on other explanatory;

proc reg data=oecd;
model gov= hours r inc;
title "Gov regressed on other explanatory";
run;

* to make prediction of last year I remove it from data;

data oecd;
point=nobs;
modify oecd nobs=nobs point=point;
remove;
stop;
run;

data oecd2;
input cons gov hours inc r;
datalines;
. 0.016254 0.005045 -0.003768 0.005812
;
run;

data oecd2;
set oecd oecd2;
run;


proc reg data=oecd2;
model cons= hours gov r inc/p cli;
title "Prediction and prediction interval model a";
run;


proc reg data=oecd2;
model cons= hours r inc/p cli;
title "Prediction and prediction interval model c";
run;







