source("data_scripts/000_includes.R")

load("workdata/wfh.RData")

annotations <- read_parquet('master_data/mt_data_avg.parquet') %>% 
  mutate(wfh_dummy = as.numeric(wfh_prob)) %>% 
  select(-wfh_prob)


wfh %>%
  filter(statistikk_aar_mnd>='2018') %>% 
  group_by(yrkeskode) %>%
  summarize(wfh_prob = mean(wfh), number_of_ads=n(), number_of_mentions=sum(wfh)) %>%
  ungroup() %>%
  mutate(relative_prob_ads = number_of_mentions/(sum(number_of_mentions))) %>% 
  filter(number_of_ads>=3) -> ads_yrke_18


annotations %>%
  inner_join(ads_yrke_18, by=c("ISCO"="yrkeskode")) -> ads_annotated18

m <- glm(wfh_dummy ~ wfh_prob , data=ads_annotated18, family = "binomial" )

summary(m)

#save(ads_annotated18, file="workdata/ads_annotated18.RData")