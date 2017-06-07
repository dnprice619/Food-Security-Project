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
collapse foodcpi, by(regioncoded) 
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

*generate dummy if tehy are in the region or not 
gen middle_east = 0 
replace middle_east =1 if regioncoded==4 

gen S_Africa = 0 
replace S_Africa = 1 if reigoncoded==7

reg sfi c.logfoodcpi##i.S_Africa c.logfoodcpi##i.middle_east i.year, r

reg sfi i.regioncoded##c.logfoodcpi i.year, r

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
