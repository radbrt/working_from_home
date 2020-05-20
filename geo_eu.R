
wfh %>%
  filter(statistikk_aar_mnd>='2018') %>% 
  group_by(yrkeskode) %>%
  summarize(wfh_prob = mean(wfh), number_of_ads=n(), number_of_mentions=sum(wfh)) %>%
  ungroup() %>%
  mutate(relative_prob_ads = number_of_mentions/(sum(number_of_mentions))) %>% 
  filter(number_of_ads>=3) -> ads_yrke_18


annotations %>%
  inner_join(ads_yrke_18, by=c("ISCO"="yrkeskode")) -> ads_annotated18

save(ads_annotated18, file="workdata/ads_annotated18.RData")

m <- glm(wfh_dummy ~ wfh_prob , data=ads_annotated18, family = "binomial" )

summary(m)


library(sf)
library(rgdal)
library(geojsonsf)
getwd()

metadata <- read_csv('ref-nuts-2016-60m.geojson/NUTS_RG_BN_60M_2016.csv')

metadata %>% 
  filter(NUTS_CODE=='NO') -> nwy

head(metadata)

e <- readOGR(dsn='ref-nuts-2016-60m.geojson/NUTS_BN_60M_2016_3035_LEVL_0.geojson', "OGRGeoJSON")

e <- read_sf('ref-nuts-2016-60m.shp/NUTS_BN_60M_2016_3035_LEVL_0.shp/', layer="SHAPEFILE")

e <- geojson_sf('ref-nuts-2016-60m.geojson/NUTS_RG_60M_2016_4326_LEVL_0.geojson')

class(e)

str(e)

ggplot(e) + geom_sf()


head(e)

e$CNTR_CODE


names(e)

e %>% 
  ggplot() +
  geom_sf() +
  coord_sf(xlim = c(-40, 50), ylim = c(30, 73), expand = FALSE) + 
  theme_bw()

head(e$NUTS_BN_ID)

names(e)

e %>% 
  group_by(NUTS_NAME, CNTR_CODE) %>% 
  summarize(n=n()) %>% 
  mutate(geocode = substr(toupper(NUTS_NAME), 1, 2)) -> mapcodes


library(janitor)
library(tidyverse)

estat_isco <- read_csv('isco1_eurostat_employment.csv') %>% 
  clean_names() %>% 
  filter(substr(geo, 1, 4)!='Euro')

estat_isco %>% 
  group_by(geo) %>% 
  summarize(n = n()) %>% 
  mutate(code = substr(toupper(geo), 1, 2))-> geocodes



special_cases <- c('United Kingdom' = 'UK', 
                   'Turkey' = 'TR', 
                   'Sweden' = 'SE', 
                   'Slovakia' = 'SK', 
                   'Slovenia' = 'SI',
                   'Switzerland' = 'CH',
                   'Serbia' = 'RS',
                   'Portugal' = 'PT',
                   'Poland' = 'PL',
                   'North Macedonia' = 'MK',
                   'Austria' = 'AT',
                   'Netherlands' = 'NL',
                   'Malta' = 'MT',
                   'Latvia' = 'LV',
                   'Lithuania' = 'LT',
                   'Iceland' = 'IS',
                   'Ireland' = 'IE',
                   'Spain' = 'ES',
                   'Estonia' = 'EE',
                   'Germany (until 1990 former territory of the FRG)' = 'DE',
                   'Denmark' = 'DK',
                   'Greece' = 'EL',
                   'Bulgaria' = 'BG',
                   'Montenegro' = 'ME')

names(special_cases)


special_cases["Sweden"]


estat_isco %>% 
  mutate(CCODE = substr(toupper(geo), 1, 2),
         CCODE_SPECIAL = special_cases[geo]) %>%
  mutate(countrycode = case_when(is.na(CCODE_SPECIAL) ~ CCODE,
                                 TRUE ~ CCODE_SPECIAL)) -> estat_isco_ccode



                





