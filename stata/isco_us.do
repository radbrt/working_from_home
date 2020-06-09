/*

This .do file is a adapted version of "country_level_measures.do", created by Dingel and Neiman and
crosswalk_oes_to_ISCO_level.do by James Stratton. 

1) four-digit ISCO codes, 
2) merge in both the Onet results 

*/

local dir "C:\Users\jia\Dropbox\COVID-19\working_home\work"
cd `dir'


* ------------------------------
* Manual labels by Dingel and Neiman 
* ------------------------------

import delimited ".\raw_data\Teleworkable_BNJDopinion.csv", clear 

rename broadgroupcode OCC_CODE

save Teleworkable_BNJDopinion, replace


* ------------------------------
* Prepare SOC to ISCO crosswalk  
* ------------------------------
import excel ".\raw_data\ISCO_SOC_Crosswalk.xls", sheet("ISCO-08 to 2010 SOC") cellrange(A7:F1132) firstrow clear
drop part
gen SOC_2010 = trim(SOCCode)
gen ISCO08_Code = trim(ISCO08Code) 
rename ISCO08TitleEN ISCO08Title 
keep ISCO08_Code SOC_2010 SOCTitle ISCO08Title 
isid ISCO08_Code SOC_2010

drop if substr(SOC_2010,1,3)=="55-" //Drops military occupations

save ISCO_4_digit_SOC_Crosswalk, replace

* ------------------------------
* Generate 2018 OES code to 6-digit SOC crosswalk   
* ------------------------------
import excel using ".\raw_data\oes_2019_hybrid_structure.xlsx", sheet(OES2019 Hybrid) cellrange(A6:H874) clear firstrow
rename (OES2018EstimatesCode OES2018EstimatesTitle) (OES_2018 OES_TITLE)
rename (G H) (SOC_2010 SOC_TITLE)
replace OES_TITLE = trim(OES_TITLE)
keep OES_2018 OES_TITLE SOC_2010 SOC_TITLE
duplicates drop
tempfile OES_SOC_temp
bys SOC_2010: egen total = total(1)
assert total==1 | SOC_2010=="25-3099" //This is many (SOC_2010) to one (OES_2018) except for SOC=25-3099 (misc teachers)
list if SOC_2010=="25-3099" //OES distinguishes between substitute teachers and others
replace SOC_2010 = OES_2018 if SOC_2010 == "25-3099" //This makes the SOC_2010 values in this crosswalk unique.
isid SOC_2010
keep OES_2018 OES_TITLE SOC_2010 SOC_TITLE
save OES_SOC_temp, replace

* ------------------------------
* Generate 2018 OES code to 4-digit ISCO crosswalk   
* ------------------------------
use ISCO_4_digit_SOC_Crosswalk, clear
drop if substr(SOC_2010,1,3)=="55-" //Drops military occupations
merge m:1 SOC_2010 using OES_SOC_temp
assert inlist(SOC_2010,"25-3099","25-3097","25-3098") if _merge!=3

replace ISCO08Title = "23 - Teaching professionals" if inlist(OES_2018,"25-3097","25-3098") & _merge==2 & missing(ISCO08_Code)==1
replace ISCO08_Code = "2359" if inlist(OES_2018,"25-3097","25-3098") & _merge==2 & missing(ISCO08_Code)==1
drop if _merge==1
drop _merge
keep ISCO08_Code ISCO08Title OES_2018 OES_TITLE
duplicates drop
sort OES_2018
clonevar OCC_CODE = OES_2018
save OES_ISCO_4digit_Crosswalk, replace
//This mapping is many (OES_2018 / OCC_CODE) to many (ISCO08_Code)

* ------------------------------
* Load US OES employment counts as weights; map to 4-digit ISCO    
* ------------------------------
* Load US employment counts 
import excel using ".\raw_data\national_M2018_dl.xlsx", firstrow clear
keep if OCC_GROUP=="detailed"

* Merge to OES codes 
merge 1:m OCC_CODE using OES_ISCO_4digit_Crosswalk

* Confirm only a small number unmerged 
assert inlist(OES_TITLE, "Fishers and Related Fishing Workers", "Hunters and Trappers") if _merge != 3 
drop if _merge != 3 
drop _merge 


* Merge to teleworkable scores (on)
merge m:1 OCC_CODE using ".\raw_data\onet_teleworkable_blscodes.dta", keep(1 3) nogen

rename teleworkable teleworkable_onet

rename TOT_EMP USA_OES_employment
bys ISCO08_Code: egen tot_emp_isco = total(USA_OES_employment) if missing(USA_OES_employment)==0 & USA_OES_employment!=0

gen weight=USA_OES_employment/tot_emp_isco 

collapse (mean) teleworkable [aweight = weight], by(ISCO08_Code)

destring ISCO08_Code, generate(isco)

save isco_us_onet, replace



