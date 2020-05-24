library(janitor)
library(tidyverse)

estat_isco <- read_csv('~/Python/working_from_home/isco1_eurostat_employment.csv') %>% 
  clean_names() %>% 
  filter(substr(geo, 1, 4)!='Euro')


wfh_isco1 <- syss_total %>% 
  group_by(ISCO1) %>% 
  summarize(total = sum(antall, na.rm=T), total_remote = sum(remote_count, na.rm=T)) %>% 
  mutate(total_remote_share = total_remote/total)
  


isco1 <- unique(estat_isco$isco08)
isco_vals <- as.character(1:9)

names(isco1) <- isco_vals

names(isco_vals) <- isco1

a <- isco_vals['Managers']

a

estat_isco %>% 
  mutate(ISCO1 = as.character(isco_vals[isco08])) %>% 
  inner_join(wfh_isco1, by='ISCO1') -> estat_wfh

estat_wfh %>% 
  group_by(geo) %>% 
  summarize(remote_share = sum(value*total_remote_share)/sum(value)) -> eu_wfh_total

write_delim(eu_wfh_total, '~/Python/working_from_home/workdata/eu_wfh_total.csv', delim = ";")

getwd()
