
local dir "C:\Users\jia\Dropbox\COVID-19\working_home\work"

cd `dir'

clear 

**************************************************************
* some isco-08 unit group occupations are not assigned on MTurk
* assign it manually
**************************************************************


input isco value sd_value wfh_dummy
1120 1 0 1
1439 1 0 1
2223 0 0 0
2224 0 0 0
3139 0 0 0
3439 0 0 0
5249 0 0 0
7319 0 0 0
end

save missing_isco, replace


**********input all answers from MTurk***********************

import delimited ".\raw_data\all_answer.csv", clear 

sort isco 

tabulate answernum, generate(g)

* aggregate over the different answers, and look at the patterns of answers
* note that not all occupations have only 5 labels, few have 10 or 15
* however, it does not impact our analysis much. For those we just scale the answers accordingly. 

collapse (mean) value p1=g1 p2=g2 p3=g3 (sd) sd_value=value (mean) wfh_dummy (count) nobs=value, by(isco) 

gen type=p1*1000+p2*100+p3*10

replace type=p2*1000+p1*100+p3*10 if p1<p2

tabulate type

generate type2=floor(type/100)

label define l1 4 "Two persons agree" 6 "Three persons agree" 8 "Four persons agree" 10 "unanimous agreement"

label values type2 l1

graph pie, over(type2) plabel(_all percent, format(%3.0f)) 

graph export "agreement.png", replace



* adding in the unlabeld occupations.
append using missing_isco

* adding in the US classification. 
merge 1:1 isco using isco_us_onet 
replace teleworkable_onet=value if missing(teleworkable_onet)


* the lower and upper bound for the marginal occupations (at most three in agreement)
gen value0=value
replace value0=0 if type2<8

gen value1=value
replace value1=1 if type2<8

tabulate wfh_dummy, su(teleworkable_onet)
tabulate wfh_dummy, su(value)

drop _merge

save isco_all, replace


************************************************
* read in Norwegian employment data 2019 *******
*************************************************

* total shares 

import delimited ".\raw_data\syss.csv", encoding(UTF-8) clear 

merge 1:1 isco using isco_all

keep if _merge==3

egen total_job=total(lønnstakere2019)

gen weight=lønnstakere2019/total_job

collapse value* wfh_dummy teleworkable_onet [aweight=weight]

di "aggregated share: "

list


* ISCO-08 Major groups: Table 1

import delimited ".\raw_data\syss.csv", encoding(UTF-8) clear 

merge 1:1 isco using isco_all

keep if _merge==3

drop _merge

preserve

egen total_job=total(lønnstakere2019)

keep if type2<8

egen total_job_marginal=total(lønnstakere2019)

keep if _n==1

* share of marginal jobs 

list

di total_job_marginal/total_job

restore


save isco_all_syss, replace


gen isco_1=floor(isco/1000)

label define isco1 1 "Managers" 2 "Professionals" 3 "Technicians and professionals" 4 "clerical support workers" 5 "Service and sales" 6 "Skilled primary workers" 7 "Craft workers" 8 "Machine Operator" 9 "Elementary"

label values isco_1 isco1


bys isco_1: egen total_job=total(lønnstakere2019)

gen weight=lønnstakere2019/total_job

collapse value value0 value1 wfh_dummy teleworkable_onet total_job [aweight=weight], by(isco_1)

label variable value "Our classification"
label variable teleworkable_onet "US classification"

list

corr value wfh_dummy teleworkable_onet

scatter value teleworkable_onet [w= total_job ], msymbol(circle_hollow) legend(off) || line teleworkable_onet teleworkable_onet, legend(off) || scatter value teleworkable_onet, msymbol(none) mlabel(isco_1) legend(off)
graph export "US_isco1.png", replace

drop total_job

save isco_all_1, replace

**************************************
* difference on wage 
**************************************

import delimited ".\raw_data\yrke_lonn_11418.csv", encoding(UTF-8) varnames(1) rowrange(2:813) clear

gen type=0 
replace type=1 if statistikkmål=="Median"

destring månedslønnkr2019, gen(monthly_wage) force

gen isco=substr(yrke,1,4)
destring isco, replace

keep type monthly_wage isco

reshape wide monthly_wage, i(isco) j(type)

rename monthly_wage0 mean_wage
rename monthly_wage1 median_wage

merge 1:1 isco using isco_all_syss

keep if _merge==3
drop _merge

gen group=2
replace group=1 if value<0.2
replace group=3 if value>0.8001

preserve

bys group: egen total_job=total(lønnstakere2019)

gen weight=lønnstakere2019/total_job
collapse mean_wage median_wage total_job (count) number=isco [aweight=weight] , by(group)
list

restore


***************************
* variation over time
***************************


use year_isco1, clear
merge 1:1 isco_1 using isco_all_1

foreach var of varlist y2011-y2019 {
egen total`var'=total(`var')
gen weight`var'=value*`var'/total`var'
egen s`var'=total(weight`var')
}

keep sy*
keep if _n==1
xpose, clear
gen year=2010+_n

graph bar v1, over(year) exclude0 yscale(range(0.35 0.4)) ylabel(0.35 0.4) ytitle("Remote work probability") b1title("Year")


graph export "time_trend.png", replace

*************************
*
* geographic differences
*
*************************

import delimited ".\raw_data\yrke_kommuner.csv", encoding(UTF-8) clear 

gen isco_1=real(substr(yrke,1,1))

merge m:1 isco_1 using isco_all_1

keep if _merge==3

bys region: egen total_job=total(lønnstakere2018)

gen weight=lønnstakere2018/total_job

collapse value wfh_dummy teleworkable_onet total_job [aweight=weight], by(region)

sort wfh_dummy

gen rank_wfh=_n

sort teleworkable_onet

gen rank_us=_n

sort value

gen rank_value=_n

label variable rank_value "Rank: our classification"
label variable rank_us "Rank: US classification"

scatter rank_value rank_us

graph export "rank_scatter.png", replace 

regress rank_value rank_us
regress rank_wfh rank_us

preserve
sort rank_us
keep teleworkable_onet region rank_us total_job
list in 1/5, table
list in 418/422, table
restore

preserve
sort rank_wfh
keep wfh_dummy region rank_wfh total_job
list in 1/5, table
list in 418/422, table
restore

preserve
sort rank_value
keep value region rank_value total_job
list in 1/5, table
list in 418/422, table
restore

*****************************************************
* employement data 2011-2019 in Norway
* ISCO-08 major groups
* obtained from SSB.no
*****************************************************

input isco_1 y2011 y2012 y2013 y2014 y2015 y2016 y2017 y2018 y2019
1	163	167	170	190	196	205	225	237	223
2	638	664	683	677	694	708	717	733	749
3	411	416	426	433	441	437	428	433	432
4	172	172	166	161	154	154	147	148	155
5	561	558	544	539	534	544	555	571	591
6	54	55	53	53	53	50	49	50	49
7	243	254	254	253	251	246	244	248	257
8	167	173	175	172	168	155	154	149	145
9	132	124	133	147	147	139	127	127	125
end 

save year_isco1.dta, replace




