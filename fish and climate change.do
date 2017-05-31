*5/18/17 dataset for final project 
*fish and climate 
cd "/Users/davidprice/Documents/q3 2017/Food Security/data for finaflf project"

clear 

set more off

use fish_climate.dta

*wish list of WB variables drop the rest that I dont need rename the ones ]
*i do need

rename ag_lnd_agri_zs ag_percent 
rename ag_lnd_arbl_zs arible_percent 
rename ag_lnd_agri_k2 total_ag_land 
rename ag_lnd_prcp_mm avg_precip 
rename ag_yld_crel_kg cereal_yield
rename eg_elc_ngas_zs percent_naturalgas
rename eg_elc_nucl_zs percent_nuclear 
rename eg_elc_petr_zs percent_oil 
rename eg_elc_rnew_zs percent_renewable 

rename eg_use_elec_k~c elec_percap

rename eg_elc_rnwx_kh production_renw
rename eg_elc_rnwx_zs production_renw_p
rename eg_use_comm_g~d electric_use
rename en_atm_co2e_g~s co2_fromgas 
rename en_atm_co2e_l~s co2_fromliquid 
rename en_atm_co2e_pc co2_percap
rename en_atm_co2e_s~s co2_solidfuel
rename en_atm_meth_k~e methanekt

rename en_clc_mdat_zs drought 
rename er_h2o_fwtl_zs freshwater_wd

rename er_lnd_ptld_zs terrestial_pro
rename er_mrn_ptmr_zs marine_pro
rename nv_agr_totl_zs agvalueadd
rename sp_pop_totl totalpop
rename sp_pop_grow popgrowth 

*whats the right outcome variable 
gen log_apro = ln(f_production) 
gen log_sapro = ln(sal_production) 
gen log_seapro = ln(sea_production) 

reg log_apro ag_percent percent_naturalgas percent_nuclear percent_oil ///
	percent_renewable elec_percap production_renw production_renw_p, r
	

reg log_apro ag_percent percent_naturalgas percent_nuclear percent_oil ///
	percent_renewable elec_percap production_renw production_renw_p i.year, r
	

areg log_apro ag_percent percent_naturalgas percent_nuclear percent_oil ///
	percent_renewable elec_percap production_renw production_renw_p i.year, absorb(countrycode) cluster(countrycode) 

areg log_sapro ag_percent percent_naturalgas percent_nuclear percent_oil ///
	percent_renewable elec_percap production_renw production_renw_p i.year, absorb(countrycode) cluster(countrycode) 

areg log_seapro ag_percent percent_naturalgas percent_nuclear percent_oil ///
	percent_renewable elec_percap production_renw production_renw_p i.year, absorb(countrycode) cluster(countrycode) 

*preserve 

areg sea_variation ag_percent percent_naturalgas percent_nuclear percent_oil ///
	percent_renewable elec_percap production_renw production_renw_p i.year, absorb(countrycode) cluster(countrycode) 

areg f_variation ag_percent percent_naturalgas percent_nuclear percent_oil ///
	percent_renewable elec_percap production_renw production_renw_p i.year, absorb(countrycode) cluster(countrycode) 

areg sal_variation ag_percent percent_naturalgas percent_nuclear percent_oil ///
	percent_renewable elec_percap production_renw production_renw_p i.year, absorb(countrycode) cluster(countrycode) 

preserve
collapse sea_variation f_variation sal_variation, by(year) 
twoway (line sea_variation year, yaxis(2))(line sal_variation year)(line f_variation year, yaxis(2)), ///
	legend(order(1 "Seafood" 2 "Saltwater Fish" 3 "Freshwater Fish")) 
restore


preserve
drop if year==2014 | year==2015 | year==2013
collapse sea_production f_production sal_production, by(year) 
twoway (line sea_production year, yaxis(2))(line sal_production year)(line f_production year, yaxis(2)), ///
	legend(order(1 "Seafood" 2 "Saltwater Fish" 3 "Freshwater Fish")) 
restore

preserve
drop if year==2014 | year==2015 | year==2013
collapse sea_domestic_supply f_domestic_supply sal_domestic_supply, by(year) 
twoway (line sea_domestic_supply year, yaxis(2))(line sal_domestic_supply year)(line f_domestic_supply year, yaxis(2)), ///
	legend(order(1 "Seafood" 2 "Saltwater Fish" 3 "Freshwater Fish")) 
restore

gen logco2percap = ln(co2_percap) 

gen logcereal = ln(cereal_yield)
preserve 
collapse logco2percap log_apro log_seapro log_sapro, by(NAMES_STD) 
twoway (scatter logco2percap log_sapro) 
twoway (scatter logco2percap log_seapro) 
twoway (scatter logco2percap log_sapro)(qfit logco2percap log_sapro)
lowess logco2percap log_sapro
restore

preserve
collapse logcereal logco2percap , by(NAMES_STD) 
twoway scatter logcereal logco2percap, mlabel(NAMES_STD) 
restore

*log exports
gen logfreshexports = ln(f_export_q)
gen logfreshimports = ln(f_import_q)
gen logsaltexports = ln(sal_export_q)
gen logsaltimports = ln(sal_import_q)
gen logseafexports = ln(sea_export_q)
gen logseafimports = ln(sea_import_q)

*per cap exports 
gen exportscapfresh = f_export_q/totalpop 
gen exportscapsalt = sal_export_q/totalpop 
gen exportscapsea = sea_export_q/totalpop

*log per cap
gen logexcapfres = ln(exportscapfresh)
gen logexcapsalt = ln(exportscapsalt)
gen logexpcapsea = ln(exportscapsea)

preserve 
collapse logco2percap logexcapfres, by(NAMES_STD) 
twoway scatter logco2percap logexcapfres, mlabel(NAMES_STD) 
restore

gen F_netexports = f_export_q - f_import_q 
gen Sa_netexports = sal_export_q - sal_import_q 
gen Se_netexports = sea_export_q - sea_import_q 

*production per capita 
gen freshprodcap = f_production/totalpop
gen salprodcap = sal_production/totalpop 
gen seaprodcap = sea_production/totalpop

gen lfreshprodcap = ln(freshprodcap) 
gen lsalprodcap = ln(salprodcap) 
gen lseaprodcap =ln(seaprodcap) 

preserve 
collapse lfreshprodcap logco2percap, by(NAMES_STD) 
twoway scatter lfreshprodcap logco2percap 
restore


*fish 
*
	
