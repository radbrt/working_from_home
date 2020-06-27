source("data_scripts/000_includes.R")

load('workdata/wfh.RData')

oldmt <- read_parquet('master_data/mt_data.parquet')

annotations <- read_parquet('master_data/mt_data.parquet') %>% 
  #mutate(wfh_dummy = wfh_prob)
  mutate(wfh_dummy <- as.numeric(wfh_dummy))


wfh %>% 
  group_by(yrkeskode) %>% 
  summarize(antall = n()) %>% 
  filter(antall>=3) -> nonminor_ads_iscos

nonminor_iscos <- intersect(nonminor_ads_iscos$yrkeskode, annotations$ISCO)

wfh %>%
  filter(statistikk_aar_mnd>'2018' & yrkeskode %in% nonminor_iscos) %>%
  mutate(ISCO1 = substr(yrkeskode,1 ,1)) %>%
  group_by(ISCO1, yrkeskode) %>%
  summarize(wfh_prob = mean(wfh)) %>%
  group_by(ISCO1) %>%
  summarise(wfh_prob_isco1 = mean(wfh_prob)) %>% 
  mutate(relative_prob_ads = wfh_prob_isco1/sum(wfh_prob_isco1) ) -> ads_st1_stats


annotations %>%
  mutate(ISCO1 = substr(ISCO,1 ,1)) %>%
  filter(ISCO %in% nonminor_iscos) %>% 
  group_by(ISCO1) %>%
  summarize(wfh_prob = mean(wfh_dummy), number_of_ads=n(), number_of_mentions=sum(wfh_dummy)) %>%
  ungroup() %>%
  mutate(relative_prob_annotations = number_of_mentions/(sum(number_of_mentions))) -> annotations_st1_stats


ads_st1_stats %>%
  inner_join(annotations_st1_stats, by='ISCO1') %>%
  select(ISCO1, relative_prob_annotations, relative_prob_ads) %>%
  mutate(relative_prob_annotations = relative_prob_annotations*100, 
         relative_prob_ads = relative_prob_ads*100) %>% 
  mutate(pctpts_diff = relative_prob_annotations-relative_prob_ads,
         ISCO1=isco_labels[ISCO1]) %>% 
  ungroup() -> ads_table


save(ads_table, file = "workdata/ads_table.RData")


ads_table %>% 
  gt()


