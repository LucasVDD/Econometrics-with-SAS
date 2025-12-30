options linesize=78;

* read in the data *;

data capm;
infile 'C:/Users/LucVa/Programming/SAS/2. CAPM/SP500TBTESLA.txt' delimiter='09'x; 
input tsl sp tb;

* compute returns on Tesla *;

rettsl = dif(log(tsl));
t=_n_;

* compute returns on SP500 *;

retsp = dif(log(sp));

* transform T-bill (page 239) *;

tbil = tb/25300;

* calculate excess returns *;

exretsp = retsp - tbil;
exrettsl = rettsl - tbil;


* estimate the CAPM model (page 239) *;

proc reg;

model exrettsl = exretsp;

run; 

* estimate the CAPM model no intercept (page 240) *;

proc reg;

model exrettsl = exretsp/noint;

run;

run;
* print 10 first datapoints *;

proc print data=capm (obs=10);
run;

