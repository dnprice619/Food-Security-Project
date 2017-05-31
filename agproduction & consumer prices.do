*5/18/17 dataset for final project 
*fish and climate 
cd "/Users/davidprice/Documents/q3 2017/Food Security/data for finaflf project"

clear

set more off

wbopendata, topics(1) long 


kountry countrycode, from(iso3c) to(iso3n) 

drop countrycode
rename _ISO3N_ countrycode 

drop if countrycode==. 

save agwbdata.dta, replace

clear 

set more off 

import delimited using "ConsumerPriceIndices_E_All_Data.csv" 

save consumerpriceswide.dta, replace

reshape long y, i(country countrycode months item) j(year) 

drop y2000f y2001f y2002f y2003f y2004f y2005f y2006f y2007f y2008f y2009f ///
	y2010f y2011f y2012f y2013f y2014f

gen cpi = 0

gen foodcpi = 0 

encode item, gen(itemcode) 

replace cpi = y if itemcode==23013
replace foodcpi = y if itemcode==23012

*collapse down to year? 
preserve 
collapse(mean) cpi foodcpi, by(countrycode country year) 

gen logcpi = ln(cpi)
gen logfoodcpi = ln(foodcpi) 

save consumerpriceslong.dta, replace 
restore

****************************************************************************************
****************************************************************************************
****************************************************************************************

clear

set more off 
use consumerpriceslong.dta

preserve 
collapse logcpi logfoodcpi, by(year) 

twoway (line logcpi year)(line logfoodcpi year), title(World Consumer Price Index Trend) ///
	subtitle("2000-2015") legend(order(1 "General CPI" 2 "Food CPI")) ytitle(Log CPI) ///
	xtitle(year) 
	
restore

*rename country codes
kountry countryname, from(other) marker 

*check what worked with renaming
tab MARKER 

tab countryname if MARKER==0 

*drop names that are not applicable to country level etc. 
drop if MARKER==0 

drop countryname 

rename NAMES_STD countryname 

save consumerpriceslong.dta, replace

*see if you can capture the lost countries here

********************************************
******************************************************************
******************************************************************


*5.30.17 
*real analysis starts here 
*Consider revising and fixing naming conventions to add observations 

clear
set more off

use agwbdata.dta
drop if year<2000

kountry countryname, from(other) marker 

tab MARKER
tab countryname if MARKER==0 
drop if MARKER==0 

drop countryname 
drop MARKER

rename NAMES_STD countryname 

merge 1:m countryname year using consumerpriceslong.dta 

drop if _merge!=3

gen logtractors = ln(ag_agr_trac_no) 

*makes some graphs 
*tractors & food cpi
preserve
collapse logfoodcpi logtractors, by(countryname) 
twoway (scatter logfoodcpi logtractors, mlabel(countryname)), title(Food CPI & Tractor Use) ///
	subtitle("Averaged Over 2000 to 2015") ytitle(Log Food CPI) xtitle(Log Number of Tractors)
restore

*fertilizer 
gen logfertilizer = ln(ag_con_fert_zs)

preserve
collapse logfoodcpi logfertilizer, by(countryname) 
twoway (scatter logfoodcpi logfertilizer) 
restore

*rename livestock
rename ag_prd_lvsk_xd lvstockindex 

preserve
collapse lvstockindex logfoodcpi, by(countryname) 
twoway scatter logfoodcpi lvstockindex, mlabel(countryname) 
restore

* cereal production
gen logcereal = ln(ag_prd_crel_mt)

preserve
collapse logfoodcpi logcereal, by(countryname) 
twoway scatter logfoodcpi logcereal, mlabel(countryname)
restore

*initial regressions
reg logfoodcpi logfertilizer lvstockindex logcereal i.year, r

areg logfoodcpi logfertilizer lvstockindex logcereal i.year, absorb(countryname) 
predict yhat

*merge in the new stuff 
preserve
collapse logcereal logfertilizer logfoodcpi, by(year)
twoway (line logcereal year, yaxis(2))(line logfertilizer year)(line logfoodcpi year) 
restore

