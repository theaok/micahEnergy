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


cd `d'

**** energy

//also more indicators here:
//http://en.wikipedia.org/wiki/List_of_countries_by_energy_consumption_per_capita
//http://en.wikipedia.org/wiki/List_of_countries_by_greenhouse_gas_emissions_per_capita


//there is some energy efficiency measure but for 16 countries only
//http://www.aceee.org/research-report/e1402
//or can simply do GDP/energy (PPP US$/ kgep) 1999 like in dias06

//tthis looks like awesome source of cross-country data http://sedac.ciesin.columbia.edu/data/collections/browse
//environmental sustainability index ESI for over 140 countries :)
//http://sedac.ciesin.columbia.edu/data/collection/esi/sets/browse
//may also look at Environmental Performance Index (EPI)

//there may be no energy use by sector, but are emissions by sector which is a good proxy of ene use--energy use and emissions correlate highhly--per jorgenson14B at above .9 http://cait2.wri.org/wri/Country%20GHG%20Emissions?indicator[]=Total%20GHG%20Emissions%20Excluding%20Land-Use%20Change%20and%20Forestry&indicator[]=Total%20GHG%20Emissions%20Including%20Land-Use%20Change%20and%20Forestry&year[]=2011&sortDir=desc&chartType=geo

//Energy use (kg of oil equivalent per capita); guess one used by jorgenson14B
//EG.USE.PCAP.KG.OE

wbopendata, indicator(NY.GDP.PCAP.KD; EG.USE.PCAP.KG.OE; SL.UEM.TOTL.ZS; EN.ATM.CO2E.PC; SP.DYN.LE00.FE.IN; IS.ROD.SGAS.PC;SP.URB.TOTL.IN.ZS)year(1980:2012)long clear

ren  ny_gdp_pcap_kd gdp
la var gdp "PCGDP"
note gdp: GDP per capita (constant 2005 US$); Code: NY.GDP.PCAP.KD; "GDP per capita is gross domestic product divided by midyear population. GDP is the sum of gross value added by all resident producers in the economy plus any product taxes and minus any subsidies not included in the value of the products. It is calculated without making deductions for depreciation of fabricated assets or for depletion and degradation of natural resources. Data are in constant 2005 U.S. dollars."; WB

ren is_rod_sgas_pc gas
la var gas "road sector gasoline fuel consumption, pc"
note gas: Road sector gasoline fuel consumption per capita (kg of oil equivalent); Code: IS.ROD.SGAS.PC; "Gasoline is light hydrocarbon oil use in internal combustion engine such as motor vehicles, excluding aircraft."; WB

ren eg_use_pcap_kg_oe ene 
la var ene "energy use, pc"
note ene:  Energy use (kg of oil equivalent per capita); Code: EG.USE.PCAP.KG.OE "Energy use refers to use of primary energy before transformation to other end-use fuels, which is equal to indigenous production plus imports and stock changes, minus exports and fuels supplied to ships and aircraft engaged in international transport."; WB
 
ren sl_uem_totl_zs un
la var un "unemployment, %"
note un: Unemployment, total (% of total labor force) (modeled ILO estimate); Code: SL.UEM.TOTL.ZS; "Unemployment refers to the share of the labor force that is without work but available for and seeking employment."; WB

ren en_atm_co2e_pc co2
la var co2 "co2 emissions, pc"
note co2: CO2 emissions (metric tons per capita); Code: EN.ATM.CO2E.PC; "Carbon dioxide emissions are those stemming from the burning of fossil fuels and the manufacture of cement. They include carbon dioxide produced during consumption of solid, liquid, and gas fuels and gas flaring."; WB
 
ren sp_dyn_le00_fe_in lexp
la var lexp "female life expectancy"
note lexp: Life expectancy at birth, female (years); Code: SP.DYN.LE00.FE.IN; "Life expectancy at birth indicates the number of years a newborn infant would live if prevailing patterns of mortality at the time of its birth were to stay the same throughout its life."
 
ren sp_urb_totl_in_zs urb
la var urb "percent urban"
note urb:  population (% of total); Code: SP.URB.TOTL.IN.ZS; "Urban population refers to people living in urban areas as defined by national statistical offices. It is calculated using World Bank population estimates and urban ratios from the United Nations World Urbanization Prospects."

d

ren iso2code cc
ren countrycode ccc
ren year yr
save `tmp'wb, replace

gen eneGdp=ene/gdp
line eneGdp yr if ccc=="USA"

collapse gdp ene un co2 lexp gas urb eneGdp, by(region yr)        
line eneGdp yr, by(region)
line ene yr, by(region)
dy


**** electricty per hh!

//may be more scientific to get it from UN:Electricity - Consumption by households
//http://data.un.org/Data.aspx?d=EDATA&f=cmID%3aEL%3btrID%3a1231
//but here it is already divided by population :)

//http://www.wec-indicators.enerdata.eu/household-electricity-use.html
//cd ~/data/energy/world
//! wget http://www.wec-indicators.enerdata.eu/xls/cuelemenele.xls
// cd `d'
import excel using ~/data/energy/world/cuelemenele.xls,clear
l in 1/3
drop in 1/2
l in 1
drop B C K L

renvars D-J \ y2005-y2011
drop in 104/105
ren A c
reshape long y, i(c)j(yr)
replace y="." if y=="n.a."
destring y, replace
ren y eleHH
la var eleHH "Average electricity consumption per electrified household, kWh"

replace c ="Hong Kong" if c=="Hong-Kong"
replace c="USA" if c=="United States"

save `tmp'couEleHH,replace

line ele yr, by(c)
dy

keep if c=="Asia"|c=="CIS"|c=="China"|c=="European Union"|c=="Latin America"|c=="Middle-East"|c=="North America"|c=="USA"|c=="World"
line ele yr, by(c)
dy

keep if c=="China"|c=="European Union"|c=="USA"|c=="World"
line ele yr, by(c)
dy

sum eleHH if yr==2011 & c=="USA", det

**** temperature

//http://www.cru.uea.ac.uk/~timm/cty/obs/TYN_CY_1_1.html
//http://www.cru.uea.ac.uk/~timm/cty/obs/TYN_CY_1_1_var-table.html

insheet using dat/TYN_CY_1_1.csv, clear 
d
ta agg
ren agg c
keep c jan jul
ren jan janMax
ren jul julMax

save `tmp'couTemp,replace



**** //MAYBE need governance, say kkz index or something!!



**** ruut //which year? nah use wvs

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



****  manheim //LATER


/* //LATER can use postmaterialist index for somethingh :) */
/* cd ~/data/eb/manheim/ */
/* ls */
/* !tar xvzf manheim.dta.gz */
/* use manheim.dta,clear */
/* rm manheim.dta */

/* alpha SATISLFE HAPPINSS */
/* //LATER so can have some index */


/* //LATER also per parties there are more vars that can use in teh FUTURE */
/* d EPPI */
/* lookfor vote */
/* lookfor party */

/* ren SATISLFE ls */
/* //la var ls "happiness" */
/* la var ls "SWB" */
/* revrs ls, replace */
/* ren YEAR yr */
/* ren NATION1 c */
/* //LATER */
/* //mention that dropped   NORTHERN IRELAND 10    */
/* //amd lumped east and west germany together,,, */
/* gen ccc="" */
/* replace ccc ="FRA"  if c ==  1 */
/* replace ccc ="BEL"  if c ==  2 */
/* replace ccc ="NLD"  if c ==  3 */
/* replace ccc ="DEU"  if c ==  4 */
/* replace ccc ="ITA"  if c ==  5 */
/* replace ccc ="LUX"  if c ==  6 */
/* replace ccc ="DNK"  if c ==  7 */
/* replace ccc ="IRL"  if c ==  8 */
/* replace ccc ="GBR"  if c ==  9 */
/* replace ccc ="GRC"  if c == 11 */
/* replace ccc ="ESP"  if c == 12 */
/* replace ccc ="PRT"  if c == 13 */
/* replace ccc ="DEU"  if c == 14 */
/* replace ccc ="NOR"  if c == 15 */
/* replace ccc ="FIN"  if c == 16 */
/* replace ccc ="SWE"  if c == 17 */
/* replace ccc ="AUT"  if c == 18 */

/* keep ls yr ccc  */
/* //LATER can think of more */

/* collapse ls, by(yr ccc) */
/* save `tmp'eb,replace    */



/* ***  merging */


/* use `tmp'eb,clear */
/* hilo ls c */
/* merge 1:1 ccc yr using `tmp'wb */
/* ta yr if _merge==1 //throwing away hunderd countries bc dropping 70s;also note that in other years one coyuntry did not merge!! */
/* keep if _merge == 3 */

/* drop if ccc=="LUX" //have to drop it--it's not a country */

/* *** desSta */

/* tw(scatter ls ene,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfit ls ene) */
/* dy */
/* ! mv /tmp/g1.pdf `tmp'couLsEne.pdf */

/* tw(scatter ls gdp,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfit ls gdp) */
/* dy */
/* ! mv /tmp/g1.pdf `tmp'couLsGdp.pdf */


/* corr ene gdp */


/* *** reg */


/* reg ls ene, robust */
/* reg ls ene gdp, robust beta */
/* reg ls ene ene2 gdp, robust beta */
/* reg ls ene ene2 gdp gdp2, robust beta */

/* reg ls ene gdp lexp, robust */

/* reg ls ene gdp lexp co2, robust */
/* reg ls ene ene2 gdp lexp co2, robust */
/* avplots */
/* dy */
/* di _b[ene]/(-2* _b[ene2]) */

/* reg ls ene gdp un lexp co2, robust //much fewer obs */

/* corr co2 ene un //aha! more ene less un and more co2 */

/* gen ene2=ene^2 */
/* gen gdp2=gdp^2 */

/* reg ls ene ene2 gdp  un lexp co2, robust */
/* di _b[ene]/(-2* _b[ene2]) */
/* sum ene, det */

/* reg ls ene ene2 gdp  gdp2 un lexp co2, robust //aha! */
/* reg ls ene  gdp  gdp2 un lexp co2, robust beta //aha! */


/* encode ccc, gen(Nccc) */
/* xtset Nccc yr */

/* //guess following jorgenson14B */
/* xtpcse ls  ene ene2 gdp lexp co2 */
/* xtpcse ls  ene ene2 gdp gdp2 un lexp co2 */
/* xtpcse ls  ene ene2 gdp un lexp co2, correlation(ar1) het */

/* //so perhaps conclusion from all that is that ene, like income contributes to happiness but up to a point--that is, tehre is a quadratoic relationship... */



**** wvs


$wvs //LATER can update my old wvs to latest incl more waves
 

keep ls yr cc
collapse ls, by(cc yr)

note ls: "All things considered, how satisfied are you with your life as a whole these days?" 1="dissatisfied" to 10="satisfied"; WVS
la var ls "happiness"

kountry cc, from(iso2c) to(iso3c)
d
l in 1/10
ren _ISO3C_ ccc

save `tmp'couWvs, replace

use `tmp'couWvs, clear
merge 1:1 ccc yr using `tmp'wb
l if _merge==1
keep if _merge==3
drop _merge
drop if ccc=="TTO"

d
ren countryname c


replace c="Bosnia-Herzegovinia" if c=="Bosnia and Herzegovina"
replace c="Egypt" if c=="Egypt, Arab Rep."
replace c="Hong Kong" if c=="Hong Kong SAR, China"
replace c="Iran" if c=="Iran, Islamic Rep."
replace c="South Korea" if c=="Korea, Rep."
replace c="Kyrgyzstan" if c=="Kyrgyz Republic"
replace c="Macedonia" if c=="Macedonia, FYR"
replace c="Moldavia" if c=="Moldova"
replace c="Belgium" if c=="Netherlands" //TODO note in paper!
replace c="Puerto Rica" if c=="Puerto Rico"
replace c="Russia" if c=="Russian Federation"
replace c="Slovakia" if c=="Slovak Republic"
replace c="USA" if c=="United States"
replace c="Venezuela" if c=="Venezuela, RB"

merge m:1 c using `tmp'couTemp
ta c if _merge==1
keep if _merge==3
drop _merge
replace  c="Netherlands" if c=="Belgium" //replacing back after merge
destring, replace

d


la var janMax "maximum temperature in January"
la var julMax "maximum temperature in July"
note janMax: "near-surface temperature maximum (degrees Celsius)" ; TYN\_CY
note julMax: "near-surface temperature maximum (degrees Celsius)" ; TYN\_CY

merge 1:1 c yr using `tmp'couEleHH
ta c if _merge==1 & yr >2004 & yr<2009
ta c if _merge==2 & yr >2004 & yr<2009
drop if _merge==2

drop _merge

saveold `tmp'worldAll,replace




**** desSta


use `tmp'worldAll, clear

d
aok_var_des , ff(ls gdp ene un co2 lexp gas urb janMax julMax) fname(`tmp'varDes.tex)
! sed -i "s|\\\$|\\\\\$|g" `tmp'varDes.tex
! sed -i "s|\%|\\\%|g" `tmp'varDes.tex

//MAYBE do regressions with collapse data as well--simpler more startgtforwrd+othersie they would ask for FE
//otherwise at least make a note that thsese are collapsed and in body we haeve uncollapsed
//otherriwise if using uncollapsed in regressions may have FE i guess
preserve

foreach v of var * {
local l`v' : variable label `v'
      if `"`l`v''"' == "" {
	local l`v' "`v'"
	}
}
collapse ls ene gdp co2 lexp eleHH janMax julMax (first) ccc (first) region (first) regioncode, by(c)
foreach v of var * {
label var `v' "`l`v''"
}


format ene gdp  lexp %9.0fc
format ls co2 %9.1f
l c ccc ls ene gdp co2 lexp if ls!=.

sort ls
aok_listtex c ccc ls ene gdp co2 lexp if ls!=., path(`tmp'list.tex) cap(Key variables for each country. Sorted on happiness. Note: if country was observed in more than one year, values are averaged) 

tw(scatter ls ene if gdp>10000,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls ene if gdp>10000, fcolor(none)),saving(ene10,replace)
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/couWvsLsEne.pdf
tw(scatter ls ene if gdp<10000,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls ene if gdp<10000, fcolor(none)),saving(ene,replace)
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/couWvsLsEneLT10kGDP.pdf


tw(scatter ls co2,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls co2 if co2<4, fcolor(none))(qfitci ls co2 if co2>4, fcolor(none))
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/co2twice.pdf

tw(scatter ls jan,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls jan if jan<13, fcolor(none))(qfitci ls jan if jan>13, fcolor(none))
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/JanTwice.pdf

tw(scatter ls jul,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls jul if jul<26.5, fcolor(none))(qfitci ls jul if jul>26.5, fcolor(none))
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/JulTwice.pdf

tw(scatter ls ene,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls ene if jan<2300, fcolor(none))(qfitci ls ene if ene>2300, fcolor(none))
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/eneTwice.pdf



tw(scatter ls gdp,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfit ls gdp)
dy
! mv /tmp/g1.pdf `tmp'couWvsLsGdp.pdf

tw(scatter ls co2,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfit ls co2)
dy

gen eneGdp=ene/gdp
la var eneGdp "energy/GDP"

tw(scatter ls eneGdp,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls eneGdp,fcolor(none))
dy

tw(scatter ls gdp ,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls gdp, fcolor(none)),saving(gdp,replace)
dy

tw(scatter ls ene ,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(vsmall) mlabcolor(black) mlabposition(0))(qfitci ls ene, fcolor(none)),saving(ene,replace)legend(off)
dy

tw(scatter ls eneGdp,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(vsmall) mlabcolor(black) mlabposition(0))(qfitci ls eneGdp,fcolor(none)),saving(eneGdp,replace)legend(off)
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/couWvsLsEnePerGdp.pdf

gr combine ene.gph eneGdp.gph, ycommon  
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/couWvsLsEnePerGdp2.pdf

gr combine gdp.gph ene.gph eneGdp.gph, ycommon imargin(0)row(1)
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/couWvsLsEnePerGdp3.pdf


tw(scatter ls eleHH,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(lfit ls eleHH),saving(a,replace)
dy

* symbols; meh not much except LCN in top left; LATER: try by income or temp etc

tw(scatter ls gdp if regionc=="EAS",mcolor(black)msize(vsmall)msymbol(diamond))(scatter ls gdp if regionc=="ECS",mcolor(black)msize(vsmall)msymbol(circle))(scatter ls gdp if regionc=="LCN",mcolor(black)msize(small)msymbol(plus))(scatter ls gdp if regionc=="MEA",mcolor(black)msize(small)msymbol(triangle))(scatter ls gdp if regionc=="NAC",mcolor(black)msize(small)msymbol(circle_hollow))(scatter ls gdp if regionc=="SAS",mcolor(black)msize(small)msymbol(diamond_hollow))(scatter ls gdp if regionc=="SSF",mcolor(black)msize(small)msymbol(square))(qfitci ls gdp, fcolor(none)),saving(gdp,replace)
dy

tw(scatter ls ene if regionc=="EAS",mcolor(black)msize(vsmall)msymbol(diamond))(scatter ls ene if regionc=="ECS",mcolor(black)msize(vsmall)msymbol(circle))(scatter ls ene if regionc=="LCN",mcolor(black)msize(small)msymbol(plus))(scatter ls ene if regionc=="MEA",mcolor(black)msize(small)msymbol(triangle))(scatter ls ene if regionc=="NAC",mcolor(black)msize(small)msymbol(circle_hollow))(scatter ls ene if regionc=="SAS",mcolor(black)msize(small)msymbol(diamond_hollow))(scatter ls ene if regionc=="SSF",mcolor(black)msize(small)msymbol(square))(qfitci ls ene, fcolor(none)),saving(ene,replace)
dy

tw(scatter ls eneGdp if regionc=="EAS",mcolor(black)msize(vsmall)msymbol(diamond))(scatter ls eneGdp if regionc=="ECS",mcolor(black)msize(vsmall)msymbol(circle))(scatter ls eneGdp if regionc=="LCN",mcolor(black)msize(small)msymbol(plus))(scatter ls eneGdp if regionc=="MEA",mcolor(black)msize(small)msymbol(triangle))(scatter ls eneGdp if regionc=="NAC",mcolor(black)msize(small)msymbol(circle_hollow))(scatter ls eneGdp if regionc=="SAS",mcolor(black)msize(small)msymbol(diamond_hollow))(scatter ls eneGdp if regionc=="SSF",mcolor(black)msize(small)msymbol(square))(qfitci ls eneGdp, fcolor(none)),saving(eneGdp,replace)
dy




*per hh
tw(scatter ls eleHH ,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls eleHH, fcolor(none)),saving(eleHH,replace)
dy
gen eleHHgdp=eleHH/gdp
tw(scatter ls eleHHgdp ,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls eleHHgdp, fcolor(none)),saving(eleHHgdp,replace)
dy
gr combine eleHH.gph eleHHgdp.gph, ycommon
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/couWvsLsEleHHgdp.pdf


restore

**** regressions



// TODO may see those recent cross country papers; essp in joural to whcih we send
//maybe add some soft vars like trust or freedom etc etc from wvs
// guess need some instutions,goivernance like kkz index


reg ls ene, robust beta
reg ls ene gdp, robust
margins, at(ene=(0(2500)10000)) 
marginsplot, x(ene) 
dy
! mv /tmp/g1.pdf `tmp'couWvsLsEneGdp.pdf

reg ls eleHH, robust beta
reg ls eleHH gdp, robust


reg ls c.ene c.co2 gdp, robust
reg ls c.ene c.co2 gdp janMax julMax urb lexp un, robust

gen enePerCo2=ene/co2 //not sure if this makes sense, guess better jsut hav the two speparately on rhs
reg ls  enePerCo2 gdp urb un lexp janMax julMax, robust

reg ls ene  janMax julMax, robust beta
reg ls ene  janMax julMax gdp, robust beta


reg ls ene gdp urb , robust //yay!
reg ls ene gdp urb janMax julMax , robust 

reg ls ene gdp urb un lexp, robust
reg ls ene gdp urb un lexp janMax julMax, robust beta
reg ls ene gdp urb un lexp janMax julMax co2, robust beta //oh co2 messes up everything!!

corr ene co2 //that's why :(

//definietly interpret substantively--how much boost in happiness from enerhy say as compare to gdp

//need year dummies in regressions!
reg ls ene gdp urb un lexp janMax julMax i.yr, robust beta
reg ls ene gdp urb un lexp janMax julMax co2 i.yr, robust beta

encode c, gen(Nc)
gen gdp2=gdp^2

reg ls ene gdp urb un lexp janMax julMax co2 i.yr, robust beta
reg ls ene gdp gdp2 urb un lexp janMax julMax co2 i.yr , robust beta

reg ls ene gdp urb un lexp janMax julMax co2 i.yr i.Nc, robust beta

reg ls ene gdp, robust
avplots,ml(ccc)
dy
! mv /tmp/g1.pdf `tmp'couWvsLsEnGdp.pdf

! acroread `tmp'couWvsLsEnGdp.pdf

gen ene2=ene^2

reg ls ene gdp co2, robust
reg ls ene gdp co2 lexp, robust
reg ls ene gdp co2 lexp un, robust
reg ls ene ene2 gdp co2 lexp un, robust

xtset Nc yr

xtreg ls ene gdp, fe
xtreg ls ene gdp urb lexp, fe
xtreg ls ene gdp urb lexp co2, fe
xtreg ls ene gdp gdp2 urb lexp co2, fe

xtreg ls ene gdp urb lexp co2, re


** paper

fvset base 2000 yr

reg ls ene i.yr, robust beta
est sto ols1
reg ls ene gdp i.yr, robust beta
est sto ols2
reg ls ene gdp urb un lexp i.yr, robust beta
est sto ols3
reg ls ene gdp urb un lexp janMax julMax i.yr, robust beta
est sto ols4
margins, at(ene=(0(2500)10000)) 
marginsplot, x(ene)saving(ols4, replace) 

reg ls ene gdp urb un lexp janMax julMax i.yr co2, robust beta
est sto ols5
margins, at(ene=(0(2500)10000)) 
marginsplot, x(ene)saving(ols5, replace) 

xtreg ls ene gdp urb un lexp , fe
est sto fe1
xtreg ls ene gdp urb un lexp co2, fe
est sto fe2

estout ols1 ols2 ols3 ols4 ols5 fe1 fe2  using  /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/regA.tex ,  cells(b(star fmt(%9.3f))) replace style(tex) collabels(, none) stats(N r2 bic aic, labels("N"))varlabels(_cons constant) label starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001)drop(*yr*)
//order(HH0 HH1 HH2 HH3 HH5 HH6 HH7 inc IS2 IS3 IS4 IS5 IS6 IS7 IS8  age age2  mar  ed  hompop  hea male )
! sed -i "s|\%|\\\%|g" /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/regA.tex

//TODO would need to multiply many vars by 1k or so that nicely can interpet

pwcorr ene gdp urb un lexp janMax julMax  co2, star(.05)

macro drop  _c*

foreach v of varlist  urb jan jul co2{
tw(qfit ene `v', ytitle("energy use")), saving(ene`v', replace)
loc cEne `cEne' ene`v'.gph
}

gr combine `cEne', ycommon row(1) imargin(0) saving(cEne, replace)   //iscale(1) prevent fornt from shrinking

foreach v of varlist  urb jan jul co2{
tw(qfit ls `v', ytitle("happiness")), saving(ls`v', replace)
loc cLs `cLs' ls`v'.gph
}
gr combine `cLs', ycommon row(1) imargin(0) saving(cLs, replace)

foreach v of varlist  urb jan jul co2{
tw(qfit gdp `v', ytitle("gdp")), saving(gdp`v', replace)
loc cGdp `cGdp' gdp`v'.gph
}
gr combine `cGdp', ycommon row(1) imargin(0) saving(cGdp, replace)

gen eneGdp=ene/gdp

foreach v of varlist  urb jan jul co2{
tw(qfit eneGdp `v', ytitle("eneGdp")), saving(eneGdp`v', replace)
loc ceneGdp `ceneGdp' eneGdp`v'.gph
}
gr combine `ceneGdp', ycommon row(1) imargin(0) saving(ceneGdp, replace)

gr combine cLs.gph cEne.gph cGdp.gph ceneGdp.gph, row(4)
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/mat1.pdf


gr matrix ene gdp urb un lexp janMax julMax  co2, half
dy



gr combine ols4.gph ols5.gph, ycommon
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/ols4ols5.pdf


//###########################################################################



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

ta yr
d
gen eneGdp=ene/gdp
tw(line ls yr, yscale(range(2.5 3.5)) ylabel(2.5[.5]3.5))(line ene yr, yaxis(2)), by(ccc)yscale(range(1000 6000) axis(2))ylabel(#2,axis(2)) //1000[3000]6000
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/ebTS.pdf

tw(line ls yr, yscale(range(2.5 3.5)) ylabel(2.5[.5]3.5))(line eneGdp yr, yaxis(2)), by(ccc)yscale(range(.05 .25) axis(2))ylabel(#4,axis(2)) //1000[3000]6000
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/ebTSeneGdp.pdf

gen eneLs=ene/ls
tw(line eneLs yr), by(ccc)
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/ebTSeneLs.pdf


bys ccc: cor ls ene
cor ls ene


preserve

foreach v of var * {
local l`v' : variable label `v'
      if `"`l`v''"' == "" {
	local l`v' "`v'"
	}
}
collapse ls ene gdp co2 lexp, by(ccc)
foreach v of var * {
label var `v' "`l`v''"
}


format ene gdp  lexp %9.0fc
format ls co2 %9.1f
l  ccc ls ene gdp co2 lexp if ls!=.


tw(scatter ls ene,mcolor(white) msize(zero) msymbol(point) mlabel(ccc)mlabsize(tiny) mlabcolor(black) mlabposition(0))(qfitci ls ene,fcolor(none))
dy
! mv /tmp/g1.pdf /home/aok/papers/ls_en/gitMicahEnergy/graphsAndTables/couLsEne.pdf

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


