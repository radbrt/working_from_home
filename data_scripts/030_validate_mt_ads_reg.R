source("data_scripts/000_includes.R")

load("workdata/wfh.RData")

annotations <- read_parquet('master_data/mt_data.parquet') %>% 
  mutate(wfh_dummy = as.numeric(wfh_dummy))


wfh %>%
  group_by(yrkeskode) %>%
  summarize(wfh_prob = mean(wfh), number_of_ads=n(), number_of_mentions=sum(wfh)) %>%
  ungroup() %>%
  mutate(relative_prob_ads = number_of_mentions/(sum(number_of_mentions))) -> ads_yrke


annotations %>%
  inner_join(ads_yrke, by=c("ISCO"="yrkeskode")) -> ads_annotated

save(ads_annotated, file="workdata/ads_annotated.RData")