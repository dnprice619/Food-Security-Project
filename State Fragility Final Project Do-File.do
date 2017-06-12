*Final project dataset 
*with actual research topic decided...
*Food Security Class
*6/6/17


clear 

cd "/Users/davidprice/Documents/q3 2017/Food Security/data for finaflf project"

set more off 

use pricefragility.dta 

*make a few exploratory graphs to explain 2 or 3 treatment variables and dependent variable 

*dependent varible 
*state fragility index variable 
sum sfi, d 

*go online and maybe code this variable to something more simple say 1,2,3 or binary 

*rather than SFI maybe use 
*Sub-categories are transformed to a 
*four-point scale (0-3) by thresholds: 0 ‘no fragility’, 1 ‘low fragility’, 
*2 ‘medium fragility’, 3 ‘high fragility’

*label variables before getting into it 

label variable sfi "State Fragility Index Score" 

label variable effect "State Effectiveness Score" 
label variable legit "State Legitimacy Score" 

label variable seceff "Security Effectiveness"

label variable secleg "Security Legitimacy" 

label variable poleff "Political Effectiveness" 

label variable polleg "Political Legitimacy" 

label variable ecoeff "Economic Effectiveness"
label variable ecoleg "Economic Legitimacy"
label variable soceff "Social Effectiveness" 
label variable socleg "Social Legitimacy" 


**GENERAL INFORMATION 
/*
State Fragility Index = Effectiveness Score + Legitimacy Score (25 points possible)
Effectiveness Score = Security Effectiveness + Political Effectiveness + Economic Effectiveness + Social Effectiveness (13 points possible)
Legitimacy Score = Security Legitimacy + Political Legitimacy + Economic Legitimacy + Social Legitimacy (12 points possible)
*/

*SFI BY REGION 
preserve
collapse sfi, by(regioncoded) 
graph bar sfi, over(regioncoded, sort(1)) asyvars note(Higher Values Indicate More Fragile States) ///
	title(Average State Fragility Index by Region) subtitle("2000 to 2015") ytitle(SFI Score) ///
	legend(order(1 "East Asia" 2 "Europe & Central Asia" 3 "Latin America" 4 "Middle East" 5 "North Africa" 6 "South Asia" 7 "Sub-Saharan Africa")size(small)) 
restore

*very little variation 
*FOOD PRICE BY REGION
preserve
collapse logfoodcpi, by(regioncoded) 
graph bar logfoodcpi, over(regioncoded, sort(1)) asyvars
restore

*logtractors logfertilizer logcereal logprecip logirrigated logarlandperson
* logfertusearea logagvalworker logperinag

*cereal yields
preserve 
collapse logcereal, by(regioncoded) 
graph bar logcereal, over(regioncoded, sort(1)) asyvars
restore

*time trend of cereal yields against changes in state fragility 
preserve
collapse sfi logcereal, by(year) 
twoway (line sfi year) (line logcereal year, yaxis(2)), title(State Fragility & Cereal Yields) ///
	subtitle("Over Time: 2000-2015") ytitle(SFI Score) ytitle(Log Yields, axis(2)) xtitle(Year) ///
	xlabel(2000(2)2015) legend(order(1 "Mean SFI" 2 "Mean Yields")) xline(2008) ///
	note(xline at year of financial crisis) 
restore

preserve 
collapse sfi logtractors, by(year) 
twoway (line sfi year)(line logtractors year, yaxis(2)) 
restore

reg sfi logtractors logcereal logfoodcpi logagvalworker, r

reg sfi logtractors logcereal logfoodcpi logagvalworker i.year, r

areg sfi logtractors logcereal logfoodcpi logagvalworker i.year, absorb(countrycoded) r

areg sfi c.logfoodcpi##c.logagvalworker logtractors logcereal i.year, absorb(countrycoded) cluster(countrycoded) 


*think about specifications 
rename ag_prd_food_xd food_pro_index

preserve
collapse food_pro_index, by(year) 
twoway line food_pro_index year
restore

areg sfi logfoodcpi food_pro_index logagvalworker logtractors logcereal i.year, ///
	absorb(countrycoded) cluster(countrycoded)
	

codebook eg_elc_accs_r~s 

rename eg_elc_accs_r~s rural_elec

areg sfi c.logfoodcpi##i.regioncoded c.food_pro_index##i.regioncoded c.logagvalworker##i.regioncoded ///
	logtractors logcereal rural_elec i.year, absorb(countrycoded) cluster(countrycoded)
 
*whats about focusing on SSF NA and ME 

preserve 
collapse sfi, by(regioncoded year) 
tab regioncoded 
twoway (line sfi year if regioncoded==4, yaxis(2))(line sfi year if regioncoded==7), ytitle(Index Middle East, axis(2)) ///
	ytitle(Index Africa) xtitle(Year) xlabel(2000(2)2015) title(State Fragility Index Over Time) subtitle("2000-2015") ///
	legend(order(1 "Middle East/North Africa" 2 "Sub Saharan Africa")) xline(2008) note(x-line at 2008) 
restore

*same thing but pull out syria and iraq 
*make iraq variable 
gen iraq = 0 
replace iraq =1 if countrycoded==61 

gen syria = 0 
replace syria = 1 if countrycoded==127 

preserve 
collapse sfi, by(regioncoded iraq syria year) 
twoway (line sfi year if regioncoded==7)(line sfi year if syria==1)(line sfi year if iraq==1), ytitle(State Fragility) ///
	xtitle(Year) xlabel(2000(2)2014) title(Syria & Iraq State Fragility) subtitle(Regional Comparisons) ///
	legend(order(1 "Sub Saharan Africa" 2 "Syria" 3 "Iraq")) ///
	xline(2008) note(x-line at 2008) 
restore

preserve 
collapse logfoodcpi, by(regioncoded iraq syria year) 
twoway (line logfoodcpi year if regioncoded==7)(line logfoodcpi year if syria==1) ///
	(line logfoodcpi year if iraq==1), ytitle(Log CPI) xtitle(Year) xlabel(2000(2)2014) ///
	legend(order(1 "Sub Saharan Africa" 2 "Syria" 3 "Iraq")) title(Iraq & Syria Food CPI) ///
	subtitle(Compared to Sub Saharan Africa) xline(2008) note(x-line at 2008) 
restore

*make syria variable 
preserve 
collapse logfoodcpi, by(regioncoded year) 
twoway (line logfoodcpi year if regioncoded==4)(line logfoodcpi year if regioncoded==7), ///
	ytitle(Log CPI) xtitle(Year) xlabel(2000(2)2014) title(Food Consumer Price Index) ///
	subtitle("2000-2015") legend(order(1 "Middle East/North Africa" 2 "Sub Saharan Africa")) ///
	xline(2008) note(x-line at 2008) 
restore

*egypt? 
*39 
gen egypt = 0 
replace egypt = 1 if countrycoded==1 

preserve 
collapse sfi logfoodcpi logcereal, by(egypt year) 
twoway (line sfi year if egypt==1)(line logcereal year if egypt==1, yaxis(2))
twoway (line sfi year if egypt==1)(line logfoodcpi year if egypt==1, yaxis(2))
restore

*yemen
*139 
gen yemen=0 
replace yemen=1 if countrycoded==139

preserve
collapse sfi logfoodcpi logcereal, by(regioncoded yemen year)
twoway (line logfoodcpi year if  yemen==1)(line sfi year if yemen==1, yaxis(2))
twoway (line sfi year if yemen==1)(line logcereal year if yemen==1, yaxis(2))
restore

*generate dummy if tehy are in the region or not 
gen middle_east = 0 
replace middle_east =1 if regioncoded==4 

gen S_Africa = 0 
replace S_Africa = 1 if regioncoded==7

reg sfi c.logfoodcpi##i.S_Africa c.logfoodcpi##i.middle_east i.year, r

reg sfi i.regioncoded##c.logfoodcpi i.year, r


*going to look at middle eastern countries in conflict
*egypt syria iraq yemen and middle east/NA as a whole 
preserve
collapse sfi logfoodcpi food_pro_index, by(egypt syria iraq yemen year) 
twoway (line sfi year if egypt==1)(line sfi year if iraq==1)(line sfi year if yemen==1) ///
	(line sfi year if syria==1), legend(order(1 "Egypt" 2 "Iraq" 3 "Yemen" 4 "Syria")) ///
	title(State Fragility Index) subtitle(Select Countries) ytitle(Index) xtitle(Year) ///
	xlabel(2000(2)2014) 
	
twoway (line food_pro_index year if egypt==1)(line food_pro_index year if iraq==1)(line food_pro_index year if yemen==1) ///
	(line food_pro_index year if syria==1), legend(order(1 "Egypt" 2 "Iraq" 3 "Yemen" 4 "Syria")) ///
	title(Food Production Index) subtitle(Select Countries) ytitle(Index) xtitle(Year) ///
	xlabel(2000(2)2014) 
	
	
twoway (line logfoodcpi year if egypt==1)(line logfoodcpi year if iraq==1)(line logfoodcpi year if yemen==1) ///
	(line logfoodcpi year if syria==1), legend(order(1 "Egypt" 2 "Iraq" 3 "Yemen" 4 "Syria")) ///
	title(Food Production Index) subtitle(Select Countries) ytitle(Index) xtitle(Year) ///
	xlabel(2000(2)2014) 
	
restore

reg sfi logfoodcpi food_pro_index i.year egypt syria yemen iraq, r 

gen ME_civilwar = 0 
replace ME_civilwar=1 if egypt==1 | syria==1 | yemen==1 | iraq==1 

areg sfi c.logfoodcpi##i.ME_civilwar food_pro_index i.year, absorb(countrycoded) cluster(countryname) 
*******Regression movement/build up

*1 --> between effect 
xtset countrycoded year

reg sfi i.regioncoded##c.logfoodcpi, cluster(countrycoded) 
est sto r1 
esttab r1
*outreg2 r1 using foodSFIreg, append excel 

reg sfi i.regioncoded##c.logfoodcpi i.year, cluster(countrycoded) 
est sto r2 
esttab r2 
*outreg2 r2 using foodSFIreg, append excel 

reg sfi i.regioncoded##c.logfoodcpi i.year i.countrycoded, cluster(countrycoded) 
est sto r3
esttab r3
*outreg2 r3 using foodSFIreg, append excel 

*same but with logagvalworker 
 
reg sfi i.regioncoded##c.logagvalworker, cluster(countrycoded) 
est sto r4
esttab r4
*outreg2 r1 using foodSFIreg, append excel 

reg sfi i.regioncoded##c.logagvalworker i.year, cluster(countrycoded) 
est sto r5 
esttab r5
*outreg2 r2 using foodSFIreg, append excel 

reg sfi i.regioncoded##c.logagvalworker i.year i.countrycoded, cluster(countrycoded) 
est sto r6
esttab r6
*outreg2 r3 using foodSFIreg, append excel 

*do this again but compare iraq and syria 




********************************************************************************
************************************************************************************************
********************************************************************************
************************************************************************************************
********************************************************************************

*same sort of analysis but now look at 4 countries of interest 

*between effect CPI --> controlling for year fixed effects
reg sfi c.logfoodcpi##i.syria c.logfoodcpi##i.iraq c.logfoodcpi##i.egypt ///
  i.year c.logfoodcpi##i.yemen, r
est sto r10
esttab r10 
*outreg2 r10 using regressresults2, append excel 


*between effect yields 
reg sfi c.logcereal##i.syria c.logcereal##i.iraq c.logcereal##i.egypt ///
  i.year c.logcereal##i.yemen, r
est sto r11
esttab r11
*outreg2 r10 using regressresults2, append excel 

*fixed effects CPI 
areg sfi c.logfoodcpi##i.syria c.logfoodcpi##i.iraq c.logfoodcpi##i.yemen ///
	c.logfoodcpi##i.egypt i.year, absorb(countrycoded) cluster(countrycoded)

*Fixed effects cereal 
areg sfi c.logcereal##i.syria c.logcereal##i.iraq c.logcereal##i.yemen ///
	c.logcereal##i.egypt i.year, absorb(countrycoded) cluster(countrycoded)

*This graph tells a crazy story 
*Syria 
preserve
collapse sfi logcereal, by(year syria) 
twoway (line sfi year if syria==1)(line logcereal year if syria==1, yaxis(2)), ///
	title(Cereal Yields vs. State Fragility) subtitle("Syria 2000-2014") ///
	legend(order(1 "SFI" 2 "Cereal")) ytitle(Index) ytitle(Log Yields, axis(2)) ///
	xtitle(Year) xlabel(2000(2)2014)
restore

*Yemen
preserve
collapse sfi logcereal, by(year yemen) 
twoway (line sfi year if yemen==1)(line logcereal year if yemen==1, yaxis(2)), ///
	title(Cereal Yields vs. State Fragility) subtitle("Yemen 2000-2014") ///
	legend(order(1 "SFI" 2 "Cereal")) ytitle(Index) ytitle(Log Yields, axis(2)) ///
	xtitle(Year) xlabel(2000(2)2014)
restore

*Egypt 
preserve
collapse sfi logcereal, by(year egypt) 
twoway (line sfi year if egypt==1)(line logcereal year if egypt==1, yaxis(2)), ///
	title(Cereal Yields vs. State Fragility) subtitle("Egypt 2000-2014") ///
	legend(order(1 "SFI" 2 "Cereal")) ytitle(Index) ytitle(Log Yields, axis(2)) ///
	xtitle(Year) xlabel(2000(2)2014)
restore 

*Iraq 
preserve
collapse sfi logcereal, by(year iraq) 
twoway (line sfi year if iraq==1)(line logcereal year if iraq==1, yaxis(2)), ///
	title(Cereal Yields vs. State Fragility) subtitle("Iraq 2000-2014") ///
	legend(order(1 "SFI" 2 "Cereal")) ytitle(Index) ytitle(Log Yields, axis(2)) ///
	xtitle(Year) xlabel(2000(2)2014)
restore 

*All World 
preserve
collapse sfi logcereal [aweight=ag_yld_crel_kg], by(year) 
twoway (line sfi year)(line logcereal year, yaxis(2)) 
restore


*change and levels of CPI 
*world
preserve
collapse logfoodcpi, by(year) 
tsset year
twoway (line D.logfoodcpi year)(line logfoodcpi year, yaxis(2)) 
restore

*syria
*world
preserve
collapse logfoodcpi if syria==1, by(year) 
tsset year
twoway (line D.logfoodcpi year)(line logfoodcpi year, yaxis(2)), title(Syira Food Price Index) ///
	subtitle("2000-2015") xtitle(Year) xlabel(2000(2)2015) legend(order(1 "First Difference Log Food Price" 2 "Log Food Price")) ///
	ytitle(Difference Log Food CPI) ytitle(Log Food CPI, axis(2))
restore

*iraq 
*
preserve
collapse logfoodcpi if iraq==1, by(year) 
tsset year
twoway (line D.logfoodcpi year)(line logfoodcpi year, yaxis(2)) 
restore

*yemen
preserve
collapse logfoodcpi if yemen==1, by(year) 
tsset year
twoway (line D.logfoodcpi year)(line logfoodcpi year, yaxis(2)) 
restore

*egypt 
*world
preserve
collapse logfoodcpi if egypt==1, by(year) 
tsset year
twoway (line D.logfoodcpi year)(line logfoodcpi year, yaxis(2)) 
restore





***************************************************************************
***************************************************************************
*6/11/17 econometric analysis for paper 

*outcome variable SFI 

*treatment variable one 
*CPI threshold binary 
gen foodcpi_dummy =  0 
replace foodcpi_dummy = 1 if logfoodcpi>5 

*second treatment 
*log cereal 

cmogram sfi foodcpi_dummy, scatter lowess


*tau graph??? 
egen min_foodcpi = min(year) if foodcpi_dummy==1, by(countryname)


gen first_foodcpi=0 

replace first_foodcpi=1 if year==min_foodcpi

gen tautau = first_foodcpi*year 

egen tautot= total(tautau), by(countryname) 

gen tau = year - min_foodcpi  

replace tau = . if tau>3| tau<-3

rename tau lagvariable

lowess sfi lagvariable, nograph gen(wowlowess) 

preserve
collapse sfi, by(lagvariable) 
lowess sfi lagvariable 
restore


*regressions 
reg sfi foodcpi_dummy i.year, r
reg sfi logfoodcpi i.year, r

reg sfi i.foodcpi_dummy##i.egypt i.foodcpi_dummy##i.syria i.foodcpi_dummy##i.iraq ///
	i.foodcpi_dummy##i.yemen i.year, r

reg sfi i.foodcpi_dummy##i.egypt i.foodcpi_dummy##i.syria i.foodcpi_dummy##i.iraq ///
	i.foodcpi_dummy##i.yemen i.year i.countrycoded, r

cmogram sfi logfoodcpi, scatter lowess 

preserve
collapse sfi logfoodcpi, by(countryname) 
twoway scatter sfi logfoodcpi, mlabel(countryname) 
restore

preserve
collapse sfi logcereal, by(countryname) 
twoway scatter sfi logcereal, mlabel(countryname) 
restore

*MERGE IN POPULATION DATA SO I CAN NORAMLIZE THE CEREAL VARIABLE 
preserve
clear 
wbopendata, long year(2000:2015) indicator(SP.POP.TOTL) 
kountry countryname, from(other) marker 
tab MARKER 
drop if MARKER==0 
drop countryname 
rename NAMES_STD countryname 
rename sp_pop_totl popcount 
keep popcount year countryname 
save populationcount.dta, replace 
restore 

drop _merge 

merge 1:1 year countryname using populationcount.dta 
keep if _merge==3 

*normalize cereal 
*cereal per kg per capita 
gen cereal_pro_cap = ag_yld_crel_kg/popcount 

kdensity cereal_pro_cap

gen logcerealcap = ln(cereal_pro_cap) 

kdensity logcerealcap

reg sfi logcerealcap i.year, r

gen cerealpro2 = ag_prd_crel_mt/popcount 

gen logcerealpro2 = ln(cerealpro2) 

reg sfi logcerealpro2 i.year, r

preserve
collapse logcerealpro2 logcerealcap, by(countryname) 
twoway scatter logcerealpro2 logcerealcap, mlabel(countryname) 
restore

preserve 
collapse logcerealcap sfi, by(countryname) 
twoway (scatter logcerealcap sfi, mlabel(countryname))(lfit logcerealcap sfi) 
restore

*USE LOG CEREAL CAP ]not logcereal 2 

preserve
collapse sfi logcerealcap logfoodcpi, by(year) 
tsset year
twoway (line logcerealcap year)(line logfoodcpi year, yaxis(2)), title(Food CPI & Cereal Yields Trends) ///
	subtitle("2000-2015") ytitle(Log Yields) ytitle(Log CPI, axis(2)) xtitle(Year) xlabel(2000(2)2015) ///
	legend(order(1 "Cereal Yields Kg per Hectare per Capita" 2 "Food CPI")) ///
	note(CPI captures changes in nominal prices) 
restore

preserve 
collapse logcerealcap logfoodcpi, by(year egypt syria) 
twoway (line logcerealcap year if egypt==1)(line logcerealcap year if syria==1) ///
	(line logfoodcpi year if egypt==1, yaxis(2))(line logfoodcpi year if syria==1, yaxis(2)), ///
	legend(order(1 "Egypt Cereal Yields" 2 "Syria Cereal Yields" 3 "Egypt Food CPI" 4 "Syria Food CPI")) ///
	ytitle(Log Yields) ytitle(Log CPI, axis(2)) xtitle(Year) xlabel(2000(2)2015) ///
	title(Food CPI & Cereal Yields Trends) subtitle(Egypt vs. Syria) ///
	note(Cereal Yields in Kg per Hecatre per Person)
restore

preserve 
collapse logcerealcap logfoodcpi, by(year iraq yemen) 
twoway (line logcerealcap year if iraq==1)(line logcerealcap year if yemen==1) ///
	(line logfoodcpi year if iraq==1, yaxis(2))(line logfoodcpi year if yemen==1, yaxis(2)), ///
	legend(order(1 "Iraq Cereal Yields" 2 "Yemen Cereal Yields" 3 "Iraq Food CPI" 4 "Yemen Food CPI")) ///
	ytitle(Log Yields) ytitle(Log CPI, axis(2)) xtitle(Year) xlabel(2000(2)2015) ///
	title(Food CPI & Cereal Yields Trends) subtitle(Iraq vs. Yemen) ///
	note(Cereal Yields in Kg per Hecatre per Person)
restore

*SFI trends 
preserve
collapse sfi, by(year iraq egypt syria yemen) 
twoway (line sfi year if egypt==1)(line sfi year if syria==1) ///
	(line sfi year if iraq==1)(line sfi year if yemen==1), title(State Fragility Index Trends) ///
	subtitle(World Compared to Select Countries) ytitle(Index Score) xtitle(Year) ///
	xlabel(2000(2)2015) legend(order(1 "Egypt" 2 "Syria" 3 "Iraq" 4 "Yemen"))
restore

*results 
reg sfi logfoodcpi egypt syria yemen iraq c.logfoodcpi##i.egypt c.logfoodcpi##i.syria ///
	 c.logfoodcpi##i.yemen  c.logfoodcpi##i.iraq, cluster(countryname) r
est sto r10
esttab r10
*outreg2 r10 using regfinal, append excel 

reg sfi logfoodcpi egypt syria yemen iraq c.logfoodcpi##i.egypt c.logfoodcpi##i.syria ///
	 c.logfoodcpi##i.yemen  c.logfoodcpi##i.iraq i.year, cluster(countryname) r
est sto r11
esttab r11
*outreg2 r11 using regfinal, append excel 

reg sfi logfoodcpi egypt syria yemen iraq c.logfoodcpi##i.egypt c.logfoodcpi##i.syria ///
	 c.logfoodcpi##i.yemen  c.logfoodcpi##i.iraq i.year i.countrycoded, cluster(countryname) r
est sto r12
esttab r12
*outreg2 r12 using regfinal, append excel 

reg sfi logcerealcap egypt syria yemen iraq c.logcerealcap##i.egypt c.logcerealcap##i.syria ///
	 c.logcerealcap##i.yemen  c.logcerealcap##i.iraq, cluster(countryname) r
est sto r13
esttab r13
*outreg2 r13 using regfinal2, append excel 

reg sfi logcerealcap egypt syria yemen iraq c.logcerealcap##i.egypt c.logcerealcap##i.syria ///
	 c.logcerealcap##i.yemen  c.logcerealcap##i.iraq i.year, cluster(countryname) r
est sto r14
esttab r14
*outreg2 r14 using regfinal2, append excel 

reg sfi logcerealcap egypt syria yemen iraq c.logcerealcap##i.egypt c.logcerealcap##i.syria ///
	 c.logcerealcap##i.yemen  c.logcerealcap##i.iraq i.year i.countrycoded, cluster(countryname) r
est sto r15
esttab r15
*outreg2 r15 using regfinal2, append excel 







