source("data_scripts/000_includes.R")

load('workdata/syss_total.RData')

nor = read_rds('master_data/gadm36_NOR_2_sf.rds')

yrke_kommune <- read_csv('master_data/yrke_kommuner.csv')

names(yrke_kommune) <- c('region', 'kjonn', 'alder', 'yrke', 'antall')

yrke_kommune %>% 
  mutate(kommnavn = str_extract(region, '[A-zøæåØÆÅ-]+'),
         kommnr = substr(region, 1, 4),
         ISCO1 = substr(yrke, 1, 1)) %>% 
  mutate(kommnavn = case_when(
    kommnr == '0528' ~ 'Østre Toten',
    kommnr == '0529' ~ 'Vestre Toten',
    kommnr == '0536' ~ 'Søndre Land',
    kommnr == '0538' ~ 'Nordre Land',
    kommnr == '0543' ~ 'Vestre Slidre',
    kommnr == '0544' ~ 'Øystre Slidre',
    kommnr == '0624' ~ 'Øvre Eiker',
    kommnr == '0625' ~ 'Nedre Eiker',
    kommnr == '0633' ~ 'Nore og Uvdal',
    kommnr == '0701' ~ 'Horten',
    kommnr == '0716' ~ 'Re',
    kommnr == '0729' ~ 'Færder',
    kommnr == '1850' ~ 'Tysfjord',
    kommnr == '1920' ~ 'Lavangen',
    kommnr == '1940' ~ 'Kåfjord',
    kommnr == '2011' ~ 'Kautokeino',
    kommnr == '2021' ~ 'Karasjok',
    kommnr == '2025' ~ 'Tana',
    kommnr == '2027' ~ 'Nesseby',
    kommnr == '0729' ~ 'Færder',
    kommnr == '0729' ~ 'Færder',
    kommnr == '5027' ~ 'Midtre Gauldal',
    kommnr == '5040' ~ 'Namdalseid',
    kommnr == '5041' ~ 'Snåsa',
    kommnr == '5043' ~ 'Røyrvik',
    kommnr == '5054' ~ 'Indre Fosen',
    TRUE ~ kommnavn
  ))  -> yrke_kommune



syss_total %>% 
  group_by(ISCO1) %>% 
  summarize(remote_pct_isco1 = sum(remote_count)/sum(antall)) %>% 
  ungroup() %>% 
  left_join(yrke_kommune, by="ISCO1") %>% 
  mutate(remote_antall = antall*remote_pct_isco1) %>% 
  group_by(kommnavn, kommnr) %>% 
  summarize(antall = sum(antall), 
            remote_antall = sum(remote_antall), 
            remote_pct = 100*sum(remote_antall)/sum(antall)
  ) %>% 
  ungroup() -> syss_total_komm

wfh_map <- merge(nor, syss_total_komm, by.x="NAME_2", by.y="kommnavn", all.x=TRUE)

save(syss_total_komm, file = "workdata/syss_total_komm.RData")
save(wfh_map, file = "workdata/wfh_map.RData")

