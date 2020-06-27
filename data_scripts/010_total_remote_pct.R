source("data_scripts/000_includes.R")

all <- read_feather('master_data/all_answers.feather') %>% 
  mutate(ISCO = as.character(ISCO),
         wfh_dummy = as.numeric(wfh_dummy))

table(all$answer, all$wfh_dummy)

all_mt <- all %>% 
  select(ISCO, wfh_dummy, confidence, wfh)

additional_answers <- "
ISCO wfh_prob
1120 1
1439 1
2223 0
2224 0
3139 0
3439 0
5249 0
7319 0"

manual_annot <- read.csv(text=additional_answers, sep=" ") %>% 
  mutate(ISCO = as.character(ISCO))

# all %>%
#   filter(answer!='Unknown') %>%
#   mutate(all_wfh = ifelse(answer=='Yes', 1, 0)) %>%
#   group_by(ISCO) %>%
#   summarize(wfh_prob = mean(all_wfh)) -> all_prob

# 
# all_comp <- all_prob %>%
#   inner_join(new_all, by="ISCO") %>%
#   mutate(diff = abs(wfh_prob-new_prob)) %>%
#   arrange(desc(diff)) -> impact_check

# all %>%
#   mutate(new_wfh = case_when(
#     answer=="Unknown" ~ 0.5,
#     answer=="Yes" ~ 1,
#     answer=="No" ~ 0,
#     TRUE ~ -1)
#   ) %>%
#   group_by(ISCO) %>%
#   summarize(new_prob = mean(new_wfh))-> new_all

all %>%
    mutate(all_wfh = case_when(
      answer=="Unknown" ~ 0.5,
      answer=="Yes" ~ 1,
      answer=="No" ~ 0,
      TRUE ~ -1)
    ) %>%
  group_by(ISCO) %>%
  summarize(wfh_prob = mean(all_wfh)) -> all_prob_mt

all_prob <- bind_rows(all_prob_mt, manual_annot)

intersect(all_prob_mt$ISCO, manual_annot$ISCO)

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