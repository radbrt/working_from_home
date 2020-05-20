library(tidyverse)
library(arrow)


subsplit <- function(s) {
  splits <- str_split(s, '_')
  tails <- lapply(splits, tail, n=1)
  unlist(tails)
}

nber <- read_csv('~/Downloads/ilostat-2020-04-10.csv') %>% 
  filter(classif1 != 'OC2_ISCO08_TOTAL') %>% 
  mutate(ISCO2 = subsplit(classif1))

frisch <- read_delim('~/Python/working_from_home/data/styrk_cen_corresponcence.csv', delim = '|', col_types = cols(.default=col_character())) %>% 
  mutate(STYRK=trimws(STYRK))

library(rhdf5)

h5ls('~/Python/working_from_home/data/mt_data.h5')



wfh <- read_csv('~/Python/working_from_home/data/mt_data.csv', col_types = cols(.default = col_character()))

wfh <- wfh %>% 
  select(ISCO, wfh)

names(wfh)

wfh <- h5read('~/Python/working_from_home/data/mt_data.h5', name='mt_data')



getwd()

stats_mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}


crosswalk98 <- crosswalk %>% 
  mutate(ISCO98 = substr(sourceCode, 1, 4)) %>% 
  group_by(ISCO98) %>% 
  summarize(ISCO08 = stats_mode(targetCode))


frisch %>% 
  inner_join(crosswalk98, by = c('STYRK'='ISCO98')) %>% 
  inner_join(wfh, by=c('ISCO08'='ISCO')) -> frisch_joined


load('~/Python/working_from_home/workdata/syss_total.RData')

isco2_shares <- syss_total %>% 
  mutate(ISCO2 = substr(ISCO, 1, 2)) %>% 
  group_by(ISCO2) %>% 
  summarize(wfh_share = weighted.mean(wfh_dummy, antall))

isco1_shares <- syss_total %>% 
  group_by(ISCO1) %>% 
  summarize(wfh_share = weighted.mean(wfh_dummy, antall))

estat_isco %>% 
  mutate(ISCO1 = isco_vals[isco08]) %>%
  inner_join(isco1_shares, by = 'ISCO1') %>% 
  group_by(geo) %>% 
  summarize(remote_pct = weighted.mean(wfh_share, value)) -> estat_wfh

annot <- read_parquet('~/Python/working_from_home/master_data/mt_data.parquet') %>% 
  mutate(wfh_dummy = as.numeric(wfh_dummy),
         ISCO = trimws(ISCO))

head(annot)

frisch_wfh <- frisch %>% 
  left_join(annot, by = c('STYRK'='ISCO'))
library(tidyverse)


#csvtext <- system("curl 'http://data.ssb.no/api/klass/v1/correspondencetables/426' -H 'Accept: text/csv; charset=UTF-8'")

crosswalk <- read_delim('~/Python/working_from_home/styrk_isco_crosswalk.csv', delim = ';', col_types = cols(.default = col_character()))

ll <- system("ls -hal", intern = T)

df <- as.data.frame(ll)

estat_isco <- read_csv('~/Python/working_from_home/isco1_eurostat_employment.csv')
library(janitor)

estat_isco <- clean_names(estat_isco)

names(estat_isco)

estat_isco <- estat_isco %>% 
  filter(substr(geo, 1, 4)!='Euro')



isco1

isco1 <- unique(estat_isco$isco08)
isco_vals <- as.character(1:9)

names(isco1) <- isco_vals

names(isco_vals) <- isco1



library(rworldmap)


wfh %>% 
  inner_join(crosswalk98, by = c('ISCO'='ISCO98')) %>% 
  inner_join(frisch, by=c('ISCO'='STYRK')) -> wfh_cenc


#  -> wfh98

