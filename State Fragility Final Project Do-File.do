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


