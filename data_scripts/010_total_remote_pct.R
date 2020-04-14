source("data_scripts/000_includes.R")

annotations <- read_parquet('master_data/mt_data.parquet') %>% 
  mutate(wfh_dummy = as.numeric(wfh_dummy))

syss <- read_parquet('data/syss.parquet')

names(syss) <- c('ISCO', 'antall')

syss %>% 
  mutate(antall = as.numeric(antall)) -> syss

# Manual check of non-matches reveal similar distribution, impute mean (=inner_join) works OK.
syss %>%
  mutate(ISCO = trimws(ISCO)) %>% 
  inner_join(annotations, on='ISCO') %>%
  mutate(remote_count = wfh_dummy*antall) -> syss_total

save(annotations, file = "workdata/annotations.RData")
save(syss_total, file = "workdata/syss_total.RData")