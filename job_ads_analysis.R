library(tidyverse)
library(arrow)

df <- read_parquet('data/stillinger_all_merged_isco08.parquet')


head(df)
min(df$statistikk_aar_mnd)



df %>%
  mutate(statistikk_aar_mnd = parse_date(statistikk_aar_mnd, format='%Y%m')) %>%
#  group_by(statistikk_aar_mnd) %>%
#  summarize(antall=n()) %>%
  ggplot(aes(statistikk_aar_mnd)) +
  geom_bar() +
  scale_x_date(breaks='1 year')


df %>%
  mutate(ISCO1 = ass_c[substr(yrkeskode, 1, 1)]) %>%
  #filter(ISCO1=='5') %>%
  group_by(statistikk_aar_mnd, ISCO1) %>%
  summarise(antall = sum(as.numeric(antall_stillinger))) %>%
  ungroup() %>%
  mutate(statistikk_aar_mnd = parse_date(statistikk_aar_mnd, format='%Y%m') ) %>%
  ggplot(aes(statistikk_aar_mnd, antall)) +
  facet_wrap(~ ISCO1) +
  geom_area(alpha=0.5) +
  geom_smooth(method = 'loess', span=0.5) +
  theme_bw()



df %>%
  mutate(ISCO1 = substr(bedrift_naring_primar_kode, 1, 2)) %>%
  #filter(ISCO1=='5') %>%
  group_by(statistikk_aar_mnd, ISCO1) %>%
  summarise(antall = sum(as.numeric(antall_stillinger))) %>%
  ungroup() %>%
  mutate(statistikk_aar_mnd = parse_date(statistikk_aar_mnd, format='%Y%m') ) %>%
  ggplot(aes(statistikk_aar_mnd, antall)) +
  facet_wrap(~ ISCO1) +
  geom_area(alpha=0.5) +
  geom_smooth(method = 'loess', span=0.5) +
  theme_bw()


df %>%
  mutate(wfh = grepl("hjemmekontor|heimekontor", stillingsbeskrivelse_vasket, ignore.case=T )) %>%
  select(isco_versjon, yrkeskode, yrke, wfh, arbeidssted_kommunenummer, arbeidssted_kommune, statistikk_aar_mnd, bedrift_naring_primar_kode) -> wfh


sum(wfh$wfh)


wfh %>%
  group_by(arbeidssted_kommunenummer) %>%
  summarise(avg_wfh = mean(wfh, na.rm=T)) %>%
  ggplot(aes(avg_wfh)) +
  geom_histogram(bins=60)

befolkning <- read_csv('/Users/radbrt/Downloads/StatBank.csv') %>%
  rename(personer = `Personer 2018`) %>%
  mutate(kommnr = substr(region, 1, 4))

names(befolkning) <- c("region", folkemengde, )

wfh %>%
  group_by(arbeidssted_kommunenummer) %>%
  summarise(avg_wfh = 100*mean(wfh, na.rm=T)) %>%
  ungroup() %>%
  inner_join(befolkning, by=c('arbeidssted_kommunenummer'='kommnr')) %>%
  ggplot(aes(personer, avg_wfh)) +
  geom_point() +
  scale_x_log10() +
  scale_y_log10()


wfh %>%
  mutate(higher = case_when(
    substr(yrkeskode,1,1) %in% c('1', '2', '3') ~ 1,
    TRUE ~ 0)) %>%
  group_by(arbeidssted_kommunenummer) %>%
  summarise(avg_wfh = (100*mean(wfh, na.rm=T))+1,
            avg_higher = 100*mean(higher, na.rm=T)) %>%
  ungroup() %>%
  inner_join(befolkning, by=c('arbeidssted_kommunenummer'='kommnr')) -> wfh_muni_pcts


  ggplot(aes(personer, avg_wfh)) +
  geom_point() +
  geom_smooth(method = 'lm') +
  scale_x_log10() +
  scale_y_log10()


library(stargazer)
m <- lm(personer ~ avg_higher, data=wfh_muni_pcts)
stargazer(m)



