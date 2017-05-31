*5//17/17


cd "/Users/davidprice/Documents/q3 2017/Food Security/data for finaflf project"

clear

set more off

use "Full FBS.dta"

*make categories for sea fish/ freshwater fish/ seafood? 
gen saltwaterfish = 0 
replace saltwaterfish = 1 if item=="Fish, Seafood" | item=="Demersal Fish" |item== "Pelagic Fish" | ///
	item=="Fish, Liver Oil" | item=="Fish, Body Oil"

gen freshwaterfish = 0 
replace freshwaterfish = 1 if item=="Freshwater Fish" 

gen seafood = 0 
replace seafood = 1 if item=="Cephalopods" | item=="Crustaceans" | item=="Molluscs, Other" | ///
	item=="Marine Fish, Other"

drop if saltwaterfish!=1 & freshwaterfish!=1 & seafood!=1

drop if element=="Food supply (kcal/capita/day)"

drop if element=="Food"

drop if element=="Feed"

drop if element=="Fat supply quantity (g/capita/day)"

drop if element=="Other uses"

drop if element=="Protein supply quantity (g/capita/day)"

drop if element=="Seed"

*domestic supply quantity 
replace elementcode=1 if elementcode==5301

*export quantity
replace elementcode=2 if elementcode==5911

*Food supply quantity 
replace elementcode=3 if elementcode==645 

*import quantity
replace elementcode=4 if elementcode==5611 

*Production 
replace elementcode=5 if elementcode==5511 

*Variation 
replace elementcode=6 if elementcode==5072 

forvalues y=1/6{
	gen check`y'= 0
	}

replace check1 = 1 if elementcode==1
replace check2 = 1 if elementcode==2
replace check3 = 1 if elementcode==3
replace check4 = 1 if elementcode==4
replace check5 = 1 if elementcode==5
replace check6 = 1 if elementcode==6

gen f_domestic_supply = 0 
gen f_export_q = 0 
gen f_import_q = 0
gen f_foodsupply_q = 0 
gen f_production = 0 
gen f_variation = 0 

gen sal_domestic_supply = 0 
gen sal_export_q = 0 
gen sal_import_q = 0
gen sal_foodsupply_q = 0 
gen sal_production = 0 
gen sal_variation = 0 

gen sea_domestic_supply = 0 
gen sea_export_q = 0 
gen sea_import_q = 0
gen sea_foodsupply_q = 0 
gen sea_production = 0 
gen sea_variation = 0 

global outcomes "domestic_supply export_q import_q foodsupply_q production variation" 

replace f_domestic_supply = value if elementcode==1 & freshwaterfish==1
replace f_export_q = value if elementcode==2 & freshwaterfish==1
replace f_import_q = value if elementcode==4 & freshwaterfish==1
replace f_foodsupply_q=value if elementcode==3 & freshwaterfish==1
replace f_production = value if elementcode==5 & freshwaterfish==1
replace f_variation = value if elementcode==6 & freshwaterfish==1

replace sal_domestic_supply = value if elementcode==1 & saltwaterfish==1
replace sal_export_q = value if elementcode==2 & saltwaterfish==1
replace sal_import_q = value if elementcode==4 & saltwaterfish==1
replace sal_foodsupply_q=value if elementcode==3 & saltwaterfish==1
replace sal_production = value if elementcode==5 & saltwaterfish==1
replace sal_variation = value if elementcode==6 & saltwaterfish==1

replace sea_domestic_supply = value if elementcode==1 & saltwaterfish==1
replace sea_export_q = value if elementcode==2 & seafood==1
replace sea_import_q = value if elementcode==4 & seafood==1
replace sea_foodsupply_q=value if elementcode==3 & seafood==1
replace sea_production = value if elementcode==5 & seafood==1
replace sea_variation = value if elementcode==6 & seafood==1

kountry country, from(other) marker 

drop if MARKER==0 

preserve
collapse (sum) f_domestic_supply f_export_q f_import_q f_foodsupply_q f_production ///
	f_variation sal_domestic_supply sal_export_q sal_import_q sal_foodsupply_q ///
	sal_production sal_variation sea_domestic_supply sea_export_q sea_import_q ///
	sea_foodsupply_q sea_production sea_variation    , by(year NAMES_STD) 

save outcomefish.dta, replace

restore 

*reduce to three seperate variables 
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

wbopendata, topics(19) long 


kountry countrycode, from(iso3c) to(iso3n) 

drop countrycode
rename _ISO3N_ countrycode 

drop if countrycode==. 

save climatewbdata.dta, replace


merge 1:m countrycode year using reducedseafoodFBS.dta 

drop if _merge!=3

clear 

use reducedseafoodFBS.dta 

*******************************************************************************
clear 

set more off

use climatewbdata.dta 

kountry countryname, from(other) marker
drop if MARKER==0 

merge 1:1 year NAMES_STD using outcomefish.dta 

keep if _merge==3 

*save 
save fish_climate.dta, replace

clear 

set more off

use fish_climate.dta




