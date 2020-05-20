
library(tidyverse)
library(arrow)

getwd()
ads <- read_parquet('Python/working_from_home/data/stillinger_all_merged_isco08.parquet')


save(wfh, file = "Python/working_from_home/wfh.RData")

load("~/Python/working_from_home/workdata/wfh.RData")
load("~/Python/working_from_home/master_data/")


min(wfh$statistikk_aar_mnd)
max(wfh$statistikk_aar_mnd)


names(wfh)


ads <- read_feather('~/Python/working_from_home/ads_annotated_full.feather')


nrow(ads)

names(ads)
head(ads)

mean(ads$wfh.x)
mean(ads$wfh_dummy, na.rm=T)

ads %>% 
  mutate(aar = as.numeric(substr(statistikk_aar_mnd, 1, 4))) %>% 
  group_by(aar, yrkeskode) %>% 
  summarize(annot_share = mean(wfh_dummy), ads_share = mean(wfh.x)) -> reg_data


library(broom)

reg_data %>% 
  group_by(aar) %>% 
  do(tidy(glm(annot_share ~ ads_share, data=.))) -> reg_results


reg_results %>% 
  filter(term=='ads_share') %>% View()


ads %>% 
  mutate(aar = as.numeric(substr(statistikk_aar_mnd, 1, 4))) %>% 
  group_by(yrkeskode) %>% 
  summarize(annot_share = mean(wfh_dummy), ads_share = mean(wfh.x)) -> all_years_reg


summary(glm(annot_share ~ ads_share, data=all_years_reg))

reg_results %>% 
  filter(term=='ads_share') %>% 
  
