source("data_scripts/000_includes.R")

ads <- read_parquet('data/stillinger_all_merged_isco08.parquet')

ads %>%
  mutate(wfh = grepl("hjemmekontor|heimekontor", stillingsbeskrivelse_vasket, ignore.case=T )) %>%
  select(isco_versjon, yrkeskode, yrke, wfh, arbeidssted_kommunenummer, statistikk_aar_mnd, 
         bedrift_naring_primar_kode, antall_stillinger) -> wfh

ads %>%
  mutate(wfh = grepl("hjemmekontor|heimekontor|hjemmefra", stillingsbeskrivelse_vasket, ignore.case=T )) %>%
  select(isco_versjon, yrkeskode, yrke, wfh, arbeidssted_kommunenummer, statistikk_aar_mnd, 
         bedrift_naring_primar_kode, antall_stillinger) -> wfh_wv

save(wfh, file="workdata/wfh.RData")

save(wfh_wv, file="workdata/wfh_wv.RData")