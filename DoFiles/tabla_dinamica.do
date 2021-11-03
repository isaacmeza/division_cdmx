import delimited  "$directory\_aux\otroscp.csv", clear
tostring cp, replace
replace cp = "0"+cp if length(cp)==4
replace cp = "00"+cp if length(cp)==3
replace cp = "000"+cp if length(cp)==2
replace cp = "0000"+cp if length(cp)==1

su area_sqkm
replace area_sqkm = (area_sqkm-`r(min)')/(`r(max)'-`r(min)')

tempfile tempocp
save `tempocp'


import delimited  "$directory\_aux\cp_exp_unique_1.csv", clear
tempfile tempcp
save `tempcp'

import delimited  "$directory\results\sub_exp_res.csv", clear
reshape long r, i(reg_sub) j(new_region)
keep if r==1

merge 1:m reg_sub using `tempcp'

tostring cp, replace
replace cp = "0"+cp if length(cp)==4
replace cp = "00"+cp if length(cp)==3
replace cp = "000"+cp if length(cp)==2
replace cp = "0000"+cp if length(cp)==1

keep reg_sub new_region num_diligencias_cpxgeo num_addr_cpxgeo cp region sub id col del
order id col del region sub reg_sub cp new_region num_diligencias_cpxgeo num_addr_cpxgeo 

merge m:1 cp using `tempocp', nogen

foreach var of varlist num_diligencias_cpxgeo num_addr_cpxgeo area_sqkm otros {
	replace `var' = 0 if missing(`var')
}
replace new_region = 0 if missing(new_region)
export delimited using "$directory\tabla_dinamica.csv", quote replace
