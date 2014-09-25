stata
clear                                  
capture set maxvar 10000
version 12                             
set more off                           
run ~/papers/root/do/aok_programs.do

loc pap ls_en
loc d = "/home/aok/papers/" + "`pap'" + "/"       

capture mkdir "`d'tex"                 
capture mkdir "`d'scr"
capture mkdir "/tmp/`pap'"

loc tmp "/tmp/`pap'/"

**** energy

//also more indicators here:
//http://en.wikipedia.org/wiki/List_of_countries_by_energy_consumption_per_capita
//http://en.wikipedia.org/wiki/List_of_countries_by_greenhouse_gas_emissions_per_capita


//there is some energy efficiency measure but for 16 countries only
//http://www.aceee.org/research-report/e1402

//Energy use (kg of oil equivalent per capita); guess one used by jorgenson14B
//EG.USE.PCAP.KG.OE

wbopendata, indicator(NY.GDP.PCAP.KD; EG.USE.PCAP.KG.OE; SL.UEM.TOTL.ZS; EN.ATM.CO2E.PC; SP.DYN.LE00.FE.IN; IS.ROD.SGAS.PC;SP.URB.TOTL.IN.ZS)year(1980:2012)long clear

ren  ny_gdp_pcap_kd gdp
la var gdp "PCGDP"

ren is_rod_sgas_pc gas
la var gas "road sector gasoline fuel consumption, pc"

ren eg_use_pcap_kg_oe ene 
la var ene "energy use, pc"

ren sl_uem_totl_zs un
la var un "unemployment"

ren en_atm_co2e_pc co2
la var co2 "co2 emissions, pc"

ren sp_dyn_le00_fe_in lexp
la var lexp "female life expectancy"

ren sp_urb_totl_in_zs urb
la var urb "percent urban"

d

ren iso2code cc
ren countrycode ccc
ren year yr
save `tmp'wb, replace



**** ruut

//which year? nah use wvs

/* insheet using `d'dat/ls_ruut_wdh.csv,clear */
/* ren code cc */
/* sort cc */
/* l if cc == cc[_n-1] */
/* merge 1:1 cc using `tmp'wb */


/* gen pcGas2=pcGas^2 */
/* gen ny_gdp_pcap_kd2=ny_gdp_pcap_kd^2 */
/* reg ls pcGas*, robust */
/* reg ls pcGas* ny*, robust */
/* reg ls pcGas ny*, robust */


/* reg ls eg_use_pcap_k ny*, robust */


/* tw(scatter ls pcGas)(lfit ls pcGas)(qfit ls pcGas) */
/* gr export `tmp'g1.eps, replace */
/* ! epstopdf `tmp'g1.eps */
/* ! acroread `tmp'g1.pdf */
/* l c if pcGas>500 & pcGas<. */

/* preserve */
/* keep if eg_use_pcap_k<10000 */
/* tw(scatter ls eg_use_pcap_k, ml(ccc))(lfit ls eg_use_pcap_k)(qfit ls eg_use_pcap_k) */
/* restore */
/* dy */


**** manheim


//LATER can use postmaterialist index for somethingh :)
cd ~/data/eb/manheim/
ls
!tar xvzf manheim.dta.gz
use manheim.dta,clear
rm manheim.dta

alpha SATISLFE HAPPINSS
//LATER so can have some index


//LATER also per parties there are more vars that can use in teh FUTURE
d EPPI
lookfor vote
lookfor party

ren SATISLFE ls
//la var ls "happiness"
la var ls "SWB"
revrs ls, replace
ren YEAR yr
ren NATION1 c
//LATER
//mention that dropped   NORTHERN IRELAND 10   
//amd lumped east and west germany together,,,
gen ccc=""
replace ccc ="FRA"  if c ==  1
replace ccc ="BEL"  if c ==  2
replace ccc ="NLD"  if c ==  3
replace ccc ="DEU"  if c ==  4
replace ccc ="ITA"  if c ==  5
replace ccc ="LUX"  if c ==  6
replace ccc ="DNK"  if c ==  7
replace ccc ="IRL"  if c ==  8
replace ccc ="GBR"  if c ==  9
replace ccc ="GRC"  if c == 11
replace ccc ="ESP"  if c == 12
replace ccc ="PRT"  if c == 13
replace ccc ="DEU"  if c == 14
replace ccc ="NOR"  if c == 15
replace ccc ="FIN"  if c == 16
replace ccc ="SWE"  if c == 17
replace ccc ="AUT"  if c == 18

keep ls yr ccc 
//LATER can think of more

collapse ls, by(yr ccc)
save `tmp'eb,replace   



****  merging


use `tmp'eb,clear
hilo ls c
merge 1:1 ccc yr using `tmp'wb
ta yr if _merge==1 //throwing away hunderd countries bc dropping 70s;also note that in other years one coyuntry did not merge!!
keep if _merge == 3

drop if ccc=="LUX" //have to drop it--it's not a country

**** desSta

tw(scatter ls ene,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfit ls ene)
dy
! mv /tmp/g1.pdf `tmp'couLsEne.pdf

tw(scatter ls gdp,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfit ls gdp)
dy
! mv /tmp/g1.pdf `tmp'couLsGdp.pdf


corr ene gdp


**** reg


reg ls ene, robust
reg ls ene gdp, robust beta
reg ls ene ene2 gdp, robust beta
reg ls ene ene2 gdp gdp2, robust beta

reg ls ene gdp lexp, robust

reg ls ene gdp lexp co2, robust
reg ls ene ene2 gdp lexp co2, robust
avplots
dy
di _b[ene]/(-2* _b[ene2])

reg ls ene gdp un lexp co2, robust //much fewer obs

corr co2 ene un //aha! more ene less un and more co2

gen ene2=ene^2
gen gdp2=gdp^2

reg ls ene ene2 gdp  un lexp co2, robust
di _b[ene]/(-2* _b[ene2])
sum ene, det

reg ls ene ene2 gdp  gdp2 un lexp co2, robust //aha!
reg ls ene  gdp  gdp2 un lexp co2, robust beta //aha!


encode ccc, gen(Nccc)
xtset Nccc yr

//guess following jorgenson14B
xtpcse ls  ene ene2 gdp lexp co2
xtpcse ls  ene ene2 gdp gdp2 un lexp co2
xtpcse ls  ene ene2 gdp un lexp co2, correlation(ar1) het



//so perhaps conclusion from all that is that ene, like income contributes to happiness but up to a point--that is, tehre is a quadratoic relationship...



**** wvs


$wvs

keep ls yr cc
collapse ls, by(cc yr)


kountry cc, from(iso2c) to(iso3c)
d
l in 1/10
ren _ISO3C_ ccc

save `tmp'couWvs, replace

use `tmp'couWvs, clear
merge 1:1 ccc yr using `tmp'wb
l if _merge==1
keep if _merge==3
drop if ccc=="TTO"


tw(scatter ls ene,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfit ls ene)
dy
! mv /tmp/g1.pdf `tmp'couWvsLsEne.pdf

tw(scatter ls gdp,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfit ls gdp)
dy
! mv /tmp/g1.pdf `tmp'couWvsLsGdp.pdf


reg ls ene, robust
reg ls ene gdp, robust

reg ls ene gdp urb, robust //yay!
reg ls ene gdp urb un lexp, robust

need tomperature!!!


avplots,ml(ccc)
dy
! mv /tmp/g1.pdf `tmp'couWvsLsEnGdp.pdf

! acroread `tmp'couWvsLsEnGdp.pdf

gen ene2=ene^2

reg ls ene gdp co2, robust
reg ls ene gdp co2 lexp, robust
reg ls ene gdp co2 lexp un, robust
reg ls ene ene2 gdp co2 lexp un, robust

