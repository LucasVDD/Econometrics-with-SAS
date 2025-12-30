 options label center nodate nonumber linesize=78;

data med;
infile 'C:/Users/LucVa/Programming/SAS/7. Fixed Effects and Random Effects Estimators/medical.dat';
input id year medexp inc age insur;
run;

proc print data=med (obs=10);		
title 'med observations';
run;

data medic;
set med;
age2 = age**2;
linc=log(inc);
run;


proc reg data=medic;
model medexp = linc age age2 insur;
title 'pooled OLS regression';
run;

/* sort prior to panel estimation */
proc sort data=medic;
by id year;
run;

proc panel data=medic;
id id year;
model medexp = linc age age2 insur / pooled hccme=4;
title 'proc panel:  pooled OLS cluster corrected standard errors';
run;


/* fixed effects using proc panel */
proc panel data=medic;
id id year;
model  medexp = linc age age2 insur / fixone;
title ' fixed effects  using PROC PANEL';
run;


/* random effects */
proc panel data=medic;
id id year;
model medexp = linc age age2 insur / ranone bp;
title 'random effects with Hausman test';
run;