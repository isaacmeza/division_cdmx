use "$directory\Raw\Domicilios_diligence_sumstat_wRegionData.dta" , clear


gen double lat = diligencia_latitud_JSON if inrange(diligencia_latitud_JSON,18,20)
replace lat = diligencia_longitud_JSON if inrange(diligencia_longitud_JSON,18,20)

gen double lon = diligencia_longitud_JSON if inrange(diligencia_longitud_JSON,-100,-98)
replace lon = diligencia_latitud_JSON if inrange(diligencia_latitud_JSON,-100,-98)

*Cleaning of particular CP's
replace cpxgeo = 3810 if cpxgeo==0
*drop Walmart
replace num_diligencias_cpxgeo = 6 if cpxgeo==2790

*Centroid
bysort cpxgeo : egen lat_c = mean(lat)
bysort cpxgeo : egen lon_c = mean(lon)

*Mode imputation
bysort cpxgeo : egen sub = mode(subregion)
bysort cpxgeo : egen col = mode(colonia)
bysort cpxgeo : egen del = mode(delegacion)

keep region cpxgeo num_diligencias_cpxgeo num_addr_cpxgeo lat_c lon_c sub col del num_diligencias_region
duplicates drop 
duplicates drop cpxgeo, force

* Clean CP
drop if missing(cpxgeo)
tostring cpx, gen(cp)
replace cp = "0"+cp if length(cp)==4
replace cp = "00"+cp if length(cp)==3
replace cp = "000"+cp if length(cp)==2
replace cp = "0000"+cp if length(cp)==1

*Cleaning of particular CP's
replace cp = "06700" if cp=="00670"

replace lat = 19.4070886 if cp=="02820"
replace lon = -99.2062773  if cp=="02820"

drop cpxgeo

egen reg_sub = group(region sub)

bysort reg_sub : egen num_diligencias_subregion = sum(num_diligencias_cpxgeo) 
order region sub reg_sub col del lat_c lon_c  cp num_diligencias_cpxgeo num_addr_cpxgeo  num_diligencias_region num_diligencias_subregion
sort region sub

export delimited using "$directory\_aux\cp_exp_unique.csv", quote replace


* STATA --------------> R