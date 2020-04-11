library(sf)
library(tidyverse)
#library(fuzzyjoin)

nor = read_rds('data/gadm36_NOR_2_sf.rds')

yrke_kommune <- read_csv('data/yrke_kommuner.csv')
names(yrke_kommune) <- c('region', 'kjonn', 'alder', 'yrke', 'antall')

yrke_kommune %>% 
  mutate(kommnavn = str_extract(region, '[A-zøæåØÆÅ-]+'),
         kommnr = substr(region, 1, 4)) %>% 
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
  )) -> yrke_kommune

yrke_kommune %>% 
  
  mutate(hk_antall = ifelse(yrke>='5', 0, antall)) %>% 
  group_by(region) %>% 
  summarize(hk_antall = sum(hk_antall), antall = sum(antall)) %>% 
  mutate(hk_andel = hk_antall/antall) -> yk_agg

mdf <- data.frame(kommnavn = trimws(nor$NAME_2)) 

yk_agg %>% 
  mutate(kommnavn = str_extract(region, '[A-zøæåØÆÅ-]+')) %>% 
  inner_join(mdf, on = "kommnavn") -> yk_agg_match

yk_agg %>% 
  mutate(kommnavn = str_extract(region, '[A-zøæåØÆÅ-\ ]+')) %>% 
  anti_join(mdf, on = "kommnavn") -> yk_agg_mismatch

#write_csv(yk_agg_mismatch , "data/mismatch.csv")
manual_fix <- read_csv('data/mismatch.csv')

yk_agg_all <-rbind(yk_agg_match, manual_fix)

write_csv(yk_agg_all, file='yrke')

nor2 <- merge(nor, yk_agg_all, by.x="NAME_2", by.y="kommnavn", all.x=TRUE)

nor2 %>% 
  ggplot() +
  geom_sf(aes(fill=hk_andel, color=hk_andel))




mdf %>% 
  
  stringdist_inner_join(yk_agg, by = "region", max_dist = 20, distance_col="dst") %>% 
  group_by(region.x) %>% 
  arrange(dst) %>% 
  filter(row_number()==1) -> mdf_total

