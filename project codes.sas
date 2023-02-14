/* Filter data for Central Minnesota */
proc sql noprint;
	create table work.CENTRALMN as select * from _TEMP0.USA_00008 where(PUMA EQ 600 
		OR PUMA EQ 900 OR PUMA EQ 1000 OR PUMA EQ 1800 OR PUMA EQ 1900);		
		
/* Remove missing values from the data set */		
proc sql noprint;
	create table work.removedna as select * from WORK.CENTRALMN where(EMPSTAT GE 1 
		AND FOODSTMP GE 1 AND POVERTY GT 0 AND EDUC GE 1);

/* Filter data for Poverty less than or equalt to 300 */
proc sql noprint;
	create table work.filter as select * from WORK.IMPORT1 where(POVERTY LE 300);

/* Creating dummy variables */
data work.dummies_created;
	set WORK.NAREMOVE;

	select (HCOVANY);
		when (1) AnyCoverage=0;
		when (2) AnyCoverage=1;
		otherwise AnyCoverage=HCOVANY;
	end;
	
	select (MARST);
		when (1) Single=0;
		when (2) Single=0;
		when (3) Single=0;
		when (4) Single=0;
		when (5) Single=0;
		when (6) Single=1;
		otherwise Single=MARST;
	end;
	
	select (SEX);
		when (1) Female=0;
		when (2) Female=1;
		otherwise Female=SEX;
	end;

	select (FOODSTMP);
		when (1) SNAP=0;
		when (2) SNAP=1;
		otherwise SNAP=FOODSTMP;
	end;
	
	select (EDUC);
		when (0) HSD=1;
		when (1) HSD=1;
		when (2) HSD=1;
		when (3) HSD=1;
		when (4) HSD=1;
		when (5) HSD=1;
		when (6) HSD=0;
		when (7) HSD=0;
		when (8) HSD=0;
		when (9) HSD=0;
		when (10) HSD=0;
		when (11) HSD=0;
		otherwise HSD=EDUC;
	end;
	
	select (EMPSTAT);
		when (1) Employed=1;
		when (2) Employed=0;
		when (3) Employed=0;
		otherwise Employed=EMPSTAT;
	end;
run;

/* Fequency tables of the variables */
proc freq data = WORK.IMPORT;
tables NCHILD Single SNAP HSD Poor Employed Female AnyCoverage PublicHealthCov /nocum;
run;

/* Summary Statistics */
proc means data=WORK.IMPORT chartype mean std min max n vardef=df;
	var NCHILD AGE POVERTY AnyCoverage Single SNAP HSD Employed Female;
	weight PERWT;
run;

proc means data=WORK.IMPORT chartype mean std min max n vardef=df;
	var NCHILD AGE POVERTY AnyCoverage Single HSD Employed Female;
	class SNAP;
	weight PERWT;
run;


/* Linear Probability Model */
proc reg data=WORK.IMPORT alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	model AnyCoverage=NCHILD AGE POVERTY Single SNAP HSD Employed Female /;
	weight PERWT;
	run;
quit;
