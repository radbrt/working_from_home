source("data_scripts/000_includes.R")

all <- read_feather('master_data/all_answers.feather') %>% 
  mutate(ISCO = as.character(ISCO))

table(all$answer, all$wfh_dummy)

all %>% 
  filter(answer!='Unknown') %>% 
  mutate(all_wfh = ifelse(answer=='Yes', 1, 0)) %>% 
  group_by(ISCO) %>% 
  summarize(wfh_prob = mean(all_wfh)) -> all_prob

write_parquet(all_prob, 'master_data/mt_data_avg.parquet')


annotations <- read_parquet('master_data/mt_data_avg.parquet')

syss <- read_parquet('data/syss.parquet')

names(syss) <- c('ISCO', 'antall')

syss %>% 
  mutate(antall = as.numeric(antall)) -> syss

# Manual check of non-matches reveal similar distribution, impute mean (=inner_join) works OK.
syss %>%
  mutate(ISCO = trimws(ISCO)) %>% 
  inner_join(annotations, on='ISCO') %>%
  mutate(remote_count = wfh_prob*antall) -> syss_total

save(annotations, file = "workdata/annotations.RData")
save(syss_total, file = "workdata/syss_total.RData")