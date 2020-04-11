library(tidyverse)

jobs <- read_delim('Data/nav_open/stillinger_all_merged.csv', ";", col_types = cols(.default=col_character()))

max(jobs$statistikk_aar_mnd)

max(substr(jobs$registrert_dato, 7, 10))

library(arrow)

jobs %>%
  filter(isco_versjon=='ISCO-08') %>%
  write_parquet("stillinger_all_merged_isco08.parquet")

library(stringr)


jobs %>%
  mutate(hk = grepl("hjemmekontor", stillingsbeskrivelse_vasket, ignore.case=T )) %>%
  select(isco_versjon, yrkeskode, yrke, hk, arbeidssted_kommunenummer, statistikk_aar_mnd) -> hjemmekontor

hjemmekontor %>%
  filter(statistikk_aar_mnd>'2017') %>%
  mutate(st1 = substr(yrkeskode,1 ,1)) %>%
  group_by(st1) %>%
  summarize(hk_prob = mean(hk)) -> hk_yrke_prob

hk_ant = sum(hjemmekontor[hjemmekontor$statistikk_aar_mnd>'2017', c('hk')]$hk)

nrow(hjemmekontor[hjemmekontor$statistikk_aar_mnd>'2017', c('hk')])

hjemmekontor %>%
  filter(statistikk_aar_mnd>'2017') %>%
  group_by(yrkeskode, yrke) %>%
  summarize(hk_prob = mean(hk), hk_antall = sum(hk), antall = n(), rel_prob = sum(hk)/hk_ant ) -> hk_st4_prob_tekst

write_delim(hk_st4_prob_tekst, "R/jobs/yrke_hjemmekontor_prob_yrkestekst.csv", delim = ";")
write_delim(hk_yrke_prob, "R/jobs/yrke_hjemmekontor_prob_styrk1.csv", delim = ";")
