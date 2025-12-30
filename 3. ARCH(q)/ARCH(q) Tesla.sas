options linesize=78;

* read in the data *;

data tesla;
infile 'C:/Users/LucVa/Programming/SAS/3. ARCH(q)/TESLA.txt';
input price;
return = dif(log(price));
t=_n_;

* squared returns lag 1, lag 2 and lag 3 *;

retsq= return**2;
retsql1 = lag(retsq);
retsql2 = lag2(retsq);
retsql3 = lag3(retsq);


* estimate the ARCH(1) model *;

proc reg;

model retsq = retsql1;

run; 

* estimate the ARCH(2) model *;

proc reg;

model retsq = retsql1 retsql2;

run;

* estimate the ARCH(3) model *;

proc reg;

model retsq = retsql1 retsql2 retsql3;

run;