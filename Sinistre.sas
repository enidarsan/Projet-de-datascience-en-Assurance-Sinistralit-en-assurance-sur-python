/*____________________________*/
/*_________PARTIE 1___________*/
/*____________________________*/


/*_______fichier word information___________*/
ods rtf file="C:\Users\zizid\Documents\assurance\information.rtf";


/*_________importer les donnees___________*/
proc import datafile='C:\Users\zizid\Documents\assurance\base_dm.xlsx'
out=DIAdata
dbms=xlsx
replace;
getname=yes;
run;

/*_________Stat UNIVARIE___________*/
/*quantitative (stat desc var quantitatives)*/
proc means data=DIAdata mean median std min max cv kurtosis skewness ;
var  polNum Age Poldur Density Bonus value Exppdays nb1 nb2;
run;
/*qualitative(stat desc var quantitatives)*/
 proc freq data=DIAdata ;
 table Gender Type Occupation Group1 Category Subgroup2 Group2 Adind Surv1 Surv2;
  run;

/*_________Matrice de correlation___________*/
/*La procédure CORR permet d’obtenir des coefficients de corrélations entre des variables ainsi que plusieurs statistiques descriptives et différents tests*/
proc corr data=DIAdata;
var Age Poldur Density Bonus value Exppdays nb1 nb2;
run;

/*_________les tableaux de freq___________*/
/*proc freq:Cette procédure permet de construire des tables représentant des distributions
statistiques à une variables ou à plusieurs variables qualitatives*/

proc freq data=DIAdata;
table Exppdays;
run;
proc freq data=DIAdata;
tables type;
run;
proc freq data=DIAdata;
tables category;
run;
proc freq data=DIAdata;
tables occupation;
run;
proc freq data=DIAdata;
tables group1;
run;
proc freq data=DIAdata;
tables adind;
run;
proc freq data=DIAdata;
tables subgroup2;
run;
proc freq data=DIAdata;
tables group2;
run;
proc freq data=DIAdata;
tables surv1;
run;
proc freq data=DIAdata;
tables Adind;
run;
*ods rtf close;

/*_________analyse bivariée___________*/

/*on changer aussi la variable gender */ 

proc freq data=DIAdata;
table Surv1*Gender;
run;
proc freq data=DIAdata;
table Surv1*type;
run;
/*etc...*/

proc tabulate DATA=DIAdata ;
class gender type;
TABLE gender="",type=""*rowpctn="";
run;
proc tabulate DATA=DIAdata ;
class gender;
var age value;
TABLE gender="",age=""*mean="Mean Age";
run;

proc tabulate DATA=DIAdata ;
class surv1;
var Exppdays;
TABLE surv1="",Exppdays=""*mean="Mean Exppdays";
run;


/*_________Distribution des variables__________*/

proc sgplot data=DIAdata;
  histogram nb1;
  density nb1  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis;
  run;

proc sgplot data=DIAdata;
  histogram bonus;
  density bonus  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis;
  run;
  
proc sgplot data=DIAdata;
  histogram density;
  density density  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis;
  run;
  
proc sgplot data=DIAdata;
  histogram Value;
  density Value  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis;
  run;

proc sgplot data=DIAdata;
  histogram Poldur;
  density Poldur  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis;
  run;
 *ods rtf close;

/*_________Recodage des variables___________*/
                   
data DIAdata_1;
set DIAdata;

/*Recodages variables numériques */
lexpdays=log(ExppDays); /*  Offset*/
bonus=bonus/100;
duree= ExppDays/365;

/*Carrés des variables continues */
Age_sq= Age*Age;
Bonus_sq= Bonus*Bonus;
Poldur_sq= Poldur*Poldur;
Density_sq= Density*Density;
value_sq= value*value ;

/*Discrétisation des variables continues */

/*Genre*/
if gender='Male' then sexe=1;
if gender='Female' then sexe=0;

/*Occupation*/
if occupation='Employed' then occup=1;
if occupation='Housewife' then occup=2;
if occupation='Retired' then occup=3;
if occupation='Self-employed' then occup=4;
if occupation='Unemployed' then occup=5;

/*Catégorie*/
if category='Small' then cat=1;
if category='Medium' then cat=2;
if category='Large' then cat=3;

/*Age*/
if age <40 then age_3cat = 1; 
if (age >=40 and age<60) then age_3cat = 2;
if age >=60 then age_3cat = 3;

/*age --> age_4cat*/
*if age <30 then age_4cat = 1; 
*if (age >=30 and age<45) then age_4cat = 2 ; /*+*/
*if (age >=45 and age<60) then age_4cat = 3 ;
*if age >=60 then age_4cat = 4 ;

/*bonus*/
if bonus < 0 then bonus_4cat = 0;
if (bonus >=0 and bonus < 0.5) then bonus_4cat = 0.5; 
if (bonus >=0.5 and bonus < 1) then bonus_4cat = 1; 
if  bonus >=1 then bonus_4cat = 1.5; 
/*bonus_______4cat*/
*if bonus <-20 then bonus_4cat = 1;
*if (bonus >=-20 and bonus < 0) then bonus_4cat = 2 ; /*+*/
*if (bonus >=0 and bonus < 60) then bonus_4cat = 3 ;
*if  bonus >=60 then bonus_4cat = 4; 

/*valeur du véhicule*/
if value<10000 then value_4cat= 1;
if (value>=10000 and value<20000) then value_4cat= 2;
if (value>=20000 and value<30000) then value_4cat= 3;
if value>=30000 then value_4cat= 4;
/*value______5cat*/
*if value<10000 then value_5cat= 1 ;  /*+*/
*if (value>=10000 and value<15000) then value_5cat= 2 ;
*if (value>=15000 and value<20000) then value_5cat= 3 ;
*if (value>=20000 and value<30000) then value_5cat= 4 ;
*if value>=30000 then value_5cat= 5 ;

/*densité*/
/*density________density_4cat*/
if Density<50 then density_4cat= 1;
if (Density>=50 and Density<150) then density_4cat= 2 /*"10-20kF"*/;
if (Density>=150 and Density<250) then density_4cat= 3 /*"20-35kF"*/;
if  Density>=250 then density_4cat= 4 /*">50kF"*/;

/*Ancienneté*/
/*poldur_______3cat*/
if poldur <5 then poldur_3cat = 1;/*+*/
if (Poldur>=5 and Poldur<10) then Poldur_3cat= 2 ;
if  Poldur>=10 then Poldur_3cat= 3;
run;

/*_________Histogrammes des variables___________*/

proc sgplot data=DIAdata_1;
  histogram age_3cat;
  density age_3cat  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis;
  run;

proc sgplot data=DIAdata_1;
  histogram bonus_4cat;
  density bonus_4cat  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis;
  run; 
  
proc sgplot data=DIAdata_1;
  histogram density_4cat;
  density density_4cat  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis;
  run; 

proc sgplot data=DIAdata_1;
  histogram Value_4cat;
  density Value_4cat  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis ;
  run;
  
proc sgplot data=DIAdata_1;
  histogram Poldur_3cat;
  density Poldur_3cat  / type=normal legendlabel='Normal' lineattrs=(pattern=solid);
  keylegend / location=inside position=topright across=1;
  xaxis;
  run; 
  

/*______modele Logit____variable exppdays comme offset_____*/
/***2****/
/*proc logistic data=mydata_1 plots=roc;
class occup (ref='1') Adind (ref='0') sexe (ref='1') bonus_4cat(ref='1');
model surv1(event='1') = sexe age_3cat cat bonus_4cat Poldur_3cat value_4cat density_4cat Adind occup / offset=lexpdays
   outroc = ROC ;
run;*/
/***1****/
ods graphics on;
proc logistic data=DIAdata_1;
class occup (ref='1') Adind (ref='0') sexe (ref='1') bonus_4cat(ref='1');
model surv1(event='1') = age  bonus Poldur value density sexe Adind occup / offset=lexpdays
outroc = ROC;
store out=data_logit;
roc; 
run;

/*_________variable exppdays comme variable explicative___________*/

ods graphics on;
proc logistic data=DIAdata_1;
class occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='2') bonus_4cat (ref='0') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model surv1(event='1') = sexe age_3cat cat bonus_4cat Poldur_3cat value_4cat density_4cat Adind occup duree; 
output out=data_logit pred= surv1predict;
roc;
run;


/*_______Modèle de poisson avec surdispersion________*/

proc GENMOD data=mydata_1;
class Group1 (ref='1') Adind (ref='1') occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='2') bonus_4cat (ref='0') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model nb1 = sexe age_3cat bonus_4cat Poldur_3cat value_4cat density_4cat Adind occup   /dist = POISSON DSCALE
OFFSET=lexpdays
LINK=LOG;
output out=data_pois pred= nbpoispredict;
run;


/*_____Modèle de poisson______*/
proc GENMOD data=DIAdata_1;
class Group1 (ref='1') Adind (ref='1') occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='2') bonus_4cat (ref='0') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model nb1 = age_3cat  Poldur_3cat density_4cat sexe Adind bonus_4cat value_4cat cat occup/dist = POISSON
OFFSET=lexpdays
LINK=LOG;
store out=data_pois;
run;



/*______Modèle ZIP______*/
proc GENMOD data=DIAdata_1;
class Group1 (ref='1') Adind (ref='1') occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='3') bonus_4cat (ref='0.5') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model nb1 = age_3cat  Poldur_3cat density_4cat sexe Adind bonus_4cat value_4cat cat occup /dist = ZIP
OFFSET=lexpdays
LINK=LOG;
ZEROMODEL bonus age age_sq  
/LINK=LOGIT;
store out=data_zip;
run;

/*Modèle ZINB*/
proc GENMOD data=DIAdata_1;
class Group1 (ref='1') Adind (ref='1') occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='3') bonus_4cat (ref='0.5') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model nb1 = age Poldur density sexe Adind bonus value_4cat cat occup /dist = ZINB
OFFSET=lexpdays
LINK=LOG;
ZEROMODEL bonus age age_sq 
/LINK=LOGIT;
store out=data_zinb;
run;
*ods rtf close;

/*_______Test de vuong_______*/

/*utiliser la macro pour comparer les modeles*/
%inc "C:/Users/zizid/Documents/assurance/Vuong1.sas";
%inc "Vuong1.sas";
PROC GENMOD data = DIAdata_1;
class Group1 (ref='1') Adind (ref='1') occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='2') bonus_4cat (ref='0') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model nb1 = age Poldur density sexe Adind bonus value_4cat cat occup  /dist = POISSON
OFFSET=lexpdays
LINK=LOG;
output out=poisson pred=predpoi;
RUN ;
PROC GENMOD data = poisson;
class Group1 (ref='1') Adind (ref='1') occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='2') bonus_4cat (ref='0') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model nb1 = age Poldur density sexe Adind bonus value_4cat cat occup /dist = NEGBIN
OFFSET=lexpdays
LINK=LOG;
output out=NB pred=prednb;
RUN ;
PROC GENMOD data = NB;
class Group1 (ref='1') Adind (ref='1') occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='3') bonus_4cat (ref='0.5') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model nb1 = age Poldur density sexe Adind bonus value_4cat cat occup /dist = ZIP
OFFSET=lexpdays
LINK=LOG;
ZEROMODEL bonus age age_sq 
/LINK=LOGIT;
output out=ZIP pred=predzip pzero=p0;
RUN ;
proc GENMOD data=ZIP;
class Group1 (ref='1') Adind (ref='1') occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='3') bonus_4cat (ref='0.5') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model nb1 = age Poldur density sexe Adind bonus value_4cat cat occup /dist = ZINB
OFFSET=lexpdays
LINK=LOG;
ZEROMODEL bonus age age_sq   
/LINK=LOGIT;
output out=ZINB pred=predzinb pzero=p1;
run;
/*test de vuong entre ZIP et POISSON*/

%Vuong(data=ZINB,response= nb1, model1=zip, p1=predzip, dist1=zip, scale1=1.00, pzero1=p0,
                        model2=poi, p2=predpoi, dist2=poi, scale2=1.00,nparm1=18,nparm2=15)
/*test de vuong entre ZINB et NB*/
%Vuong(data=ZINB,response= nb1, model1=zinb, p1=predzinb, dist1=zinb, scale1=0.0906 ,pzero1=p1,
                        model2=NB, p2=prednb, dist2=nb, scale2=0.3625,nparm1=19,nparm2=16)
/*test de vuong entre ZIP et ZINB*/
%Vuong(data=ZINB,response= nb1, model1=zinb, p1=predzinb, dist1=zinb, scale1=0.0906,  pzero1=p1,pzero2=p0,
                        model2=zip, p2=predzip, dist2=zip, scale2=1.00,nparm1=19,nparm2=18)

;

/*____________________________*/
/*_________PARTIE 2___________*/
/*____________________________*/

/*________Prévision pricing________*/
proc import datafile="C:\Users\zizid\Documents\assurance\pricing.csv"
  out=data_pred dbms=dlm replace;
  delimiter=";";
  getnames=yes;
run;

/*__________recodage data pricing____________*/
data data_pred_1;
set data_pred;

lexpdays=log(365);
age_sq=age*age;
bonus=bonus/100;

if gender='Male' then sexe=1;
if gender='Female' then sexe=0;

if occupation='Employed' then occup=1;
if occupation='Housewife' then occup=2;
if occupation='Retired' then occup=3;
if occupation='Self-employed' then occup=4;
if occupation='Unemployed' then occup=5;

if category='Small' then cat=1;
if category='Medium' then cat=2;
if category='Large' then cat=3;

if age <40 then age_3cat = 1; 
if (age >=40 and age<60) then age_3cat = 2;
if age >=60 then age_3cat = 3 /*60+*/;

/*bonus*/
if bonus < 0 then bonus_4cat = 0;
if (bonus >=0 and bonus < 0.5) then bonus_4cat = 0.5; 
if (bonus >=0.5 and bonus < 1) then bonus_4cat = 1; 
if  bonus >=1 then bonus_4cat = 1.5; 

/*valeur du véhicule*/
if value<10000 then value_4cat= 1 /*"<10kF"*/;
if (value>=10000 and value<20000) then value_4cat= 2 /*"10-20kF"*/;
if (value>=20000 and value<30000) then value_4cat= 3 /*"20-35kF"*/;
if value>=30000 then value_4cat= 4 /*">35kF"*/;


/*densité*/
if Density<50 then density_4cat= 1;
if (Density>=50 and Density<150) then density_4cat= 2 /*"10-20kF"*/;
if (Density>=150 and Density<250) then density_4cat= 3 /*"20-35kF"*/;
if  Density>=250 then density_4cat= 4 /*">50kF"*/;

/*Ancienneté*/
if Poldur<5 then Poldur_3cat= 1;
if (Poldur>=5 and Poldur<10) then Poldur_3cat= 2 ;
if  Poldur>=10 then Poldur_3cat= 3;
run;

/*_____Prévision: modèle Logit_____*/

ods graphics on;
proc logistic data=DIAdata_1;
class occup (ref='1') cat (ref='2') sexe (ref='1') age_3cat (ref='2') bonus_4cat (ref='0') value_4cat (ref='1') density_4cat (ref='1') Poldur_3cat (ref='2');
model surv1(event='1') = sexe age_3cat cat bonus_4cat Poldur_3cat value_4cat density_4cat Adind occup duree; 
score data=data_logit out = surv1predict;
roc;
run;

proc plm source=data_logit;
score data=DATA_PRED_1 out=preds pred=Surv1 /ilink;
run;

/*_______Prévision: modèle de Poisson________*/
proc plm source=data_pois;
score data=preds out=preds1 pred=Freq1 /ilink;
run;
proc means data=preds1;
var Freq1;
run;

/*________Prévision: modèle BN__________*/
proc plm source=data_negbin;
score data=preds1 out=preds2 pred=Freq2 /ilink;
run;

/*_________Prévision: modèle ZIP_________*/
proc plm source=data_zip;
score data=preds2 out=preds3 pred=Freq3 /ilink;
run;

/*_________Prévision: modèle ZINB__________*/
proc plm source=data_zinb;
score data=preds3 out=preds4 pred=Freq4 /ilink;
run;

/*_______Données de prévisions______*/
DATA Pricing_Pred ;
SET preds4(KEEP=PolNum Surv1 Freq1 Freq2 Freq3 Freq4) ;
 
proc means data=preds4;
 var Surv1 Freq1 Freq2 Freq3 Freq4;
run;

