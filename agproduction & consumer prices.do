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

*precipitation and food prices? 
rename ag_lnd_prcp_mm avgprecip 

kdensity avgprecip, normal 

gen logprecip = ln(avgprecip)

kdensity logprecip, normal 

preserve
collapse logfoodcpi avgprecip, by(year) 
twoway scatter logfoodcpi avgprecip 
restore

*Precipitation doesnt have enough observations to really use in this analysis 
*what other variables would be the righ choice? 

*irrigated land 
codebook ag_lnd_irig_a~s 

rename ag_lnd_irig_a~s landirrigated 

kdensity landirrigated, normal 

gen logirrigated = ln(landirrigated) 

preserve
collapse logfoodcpi logirrigated, by(countryname) 

twoway scatter logfoodcpi logirrigated
restore

*arable land per person 
rename ag_lnd_arbl_h~c arlandprperson

kdensity arlandprperson, normal 

gen logarlandperson = ln(arlandprperson) 

preserve
collapse logfoodcpi logarlandperson, by(countryname) 
twoway (lfit logfoodcpi logarlandperson)(scatter logfoodcpi logarlandperson, mlabel(countryname))
restore

preserve 
collapse logfoodcpi logarlandperson, by(year) 
twoway (line logfoodcpi year)(line logarlandperson year) 
restore

*log food cpi by region....price changes and regions 
tab regioncode 

encode regioncode, gen(regioncoded) 

*simplify regions 
preserve
collapse logfoodcpi, by(regioncoded year) 
twoway (line logfoodcpi year if regioncoded==1)(line logfoodcpi year if regioncoded==2) ///
	(line logfoodcpi year if regioncoded==3)(line logfoodcpi year if regioncoded==4) ///
	(line logfoodcpi year if regioncoded==5)(line logfoodcpi year if regioncoded==6) ///
	(line logfoodcpi year if regioncoded==7), title(Food CPI Trends) subtitle(By Region) ///
	legend(order(1 "East Asia & Pacific" 2 "Europe & Central Asia" 3 "Latin America" 4 "Middle East & North Africa" 5 "North America" 6 "South Asia" 7 "Sub-Saharan Africa")size(small)) ///
	xtitle(Year) ytitle(Log CPI) xlabel(2000(2)2014) 
restore

*fertilizer intensity by land area
rename ag_con_fert_zs fertilizerhect

kdensity fertilizerhect, normal 

gen logfertusearea = ln(fertilizerhect) 

kdensity logfertusearea, normal 

*graph 
preserve
collapse logfertusearea logfoodcpi, by(countryname)
twoway (scatter logfertusearea logfoodcpi, mlabel(countryname))(lfit logfertusearea logfoodcpi)
restore

preserve 
collapse logfertusearea logfoodcpi, by(year) 
twoway (line logfertusearea year)(line logfoodcpi year) 
restore

*regression check 
reg logfoodcpi logfertusearea i.regioncoded, r

reg logfoodcpi logfertusearea i.year, r

areg logfoodcpi c.logfertusearea##i.regioncoded, absorb(countryname) cluster(countryname) 

*code countrynames 
encode countryname, gen(countrycoded) 

reg logfoodcpi logfertusearea c.year##i.countrycoded i.year, cluster(countryname) 

cmogram logfoodcpi logfertusearea, scatter lowess

*between country effect and than within effect 

*agg value added per worker
rename ea_prd_agri_kd aggvalworker 

kdensity aggvalworker, normal 

gen logagvalworker = ln(aggvalworker) 

kdensity logagvalworker, normal 

preserve
collapse logfoodcpi logagvalworker, by(countryname) 
twoway scatter logfoodcpi logagvalworker, mlabel(countryname) 
restore

*collinearity of fertilizer and added value per worker 
preserve 
collapse logfertusearea logagvalworker, by(countryname) 
twoway (lfitci logfertusearea logagvalworker)(scatter logfertusearea logagvalworker, mlabel(countryname)) 
restore

preserve
collapse logfertusearea logagvalworker logfoodcpi, by(year) 
twoway (line logfertusearea year)(line logagvalworker year, yaxis(2))(line logfoodcpi year), ///
	legend(order(1 "Fertilizer Use per Hectre" 2 "Agricultural Added Value per Worker" 3 "Food CPI")size(small)) ///
	ytitle(Log Value) ytitle(Log Value Ag., axis(2))
restore

areg logfoodcpi logagvalworker logfertusearea i.year, absorb(countrycoded) cluster(countrycoded) 

cmogram logfoodcpi logagvalworker, scatter lowess 


*perecent total emp. in ag 
rename sl_agr_empl_zs percentinag 

gen logperinag = ln(percentinag) 

gen y2008 = 0 

replace y2008=1 if year==2008

cmogram logfoodcpi year, scatter lowess 

preserve
collapse logfoodcpi, by(year) 
twoway line logfoodcpi year
restore

*check differences between log and not log verisions of CPI 
*clearly a major difference between the two 


preserve
collapse logfoodcpi foodcpi, by(year) 
twoway (line logfoodcpi year)(line foodcpi year, yaxis(2))
restore

twoway scatter logfoodcpi logcpi, mlabel(countryname) 

areg logfoodcpi i.y2008##i.regioncoded i.year, absorb(countrycoded) r

********************************************************************************
********************************************************************************
********************************************************************************

********************************************************************************
********************************************************************************
*import state fragility index data 
duplicates tag countryname year, gen(duptag) 
tab duptag
drop if duptag==1 

drop duptag 
save logfoodcpidataset.dta, replace 

clear

set more off 

import delimited using "SFIv2015-2.csv"

*check naming conventions for merge
kountry country, from(other) mark 

tab MARKER 

drop if MARKER==0 

rename NAMES_STD countryname 
drop country
*drop years that i dont need 
drop if year<2000
drop region 



merge 1:1 countryname year using logfoodcpidataset.dta 

keep if _merge==3

save pricefragility.dta, replace


***************************************************************************
************************************************************
reg sfi logfoodcpi, r

preserve
collapse sfi logfoodcpi, by(countryname) 
twoway scatter sfi logfoodcpi, yaxis(2) mlabel(countryname) 
restore

areg sfi c.logfoodcpi##i.regioncoded i.year, absorb(countrycoded) r 

*think about coding the SFI variable to be in more clear definitions... or multi tiered 

*check out other variables in dataset 

clear 

cd "/Users/davidprice/Documents/q3 2017/Food Security/data for finaflf project"

set more off 

use pricefragility.dta 

preserve
collapse sfi, by(year regioncoded)
tab regioncoded
twoway (line sfi year if regioncoded==1)(line sfi year if regioncoded==2) ///
	(line sfi year if regioncoded==3)(line sfi year if regioncoded==4) ///
	(line sfi year if regioncoded==5)(line sfi year if regioncoded==6) ///
	(line sfi year if regioncoded==7)

restore

*time series 
preserve 
collapse sfi logfoodcpi, by(year)
twoway (line sfi year)(line logfoodcpi year, yaxis(2)), ytitle(Log CPI) ytitle(State Fragility Index, axis(2)) ///
	title(Trend of State Fragility Index & Food CPI) subtitle("2000 to 2015") xtitle(Year) xlabel(2000(2)2015)
restore

*cross section
preserve 
collapse sfi logfoodcpi, by(countryname) 
twoway (lfitci sfi logfoodcpi)(scatter sfi logfoodcpi, mlabel(countryname))
restore





