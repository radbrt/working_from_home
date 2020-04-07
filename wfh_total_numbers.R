

annotations <- read_parquet('data/mt_data.parquet') %>%
  mutate(ISCO = trimws(ISCO))


syss <- read_parquet('data/syss.parquet')

names(syss) <- c('ISCO', 'antall')

syss %>%
  mutate(ISCO = trimws(ISCO)) -> syss

# Somehow one duplicate, no matter.
annotations %>%
  group_by(ISCO) %>%
  summarize(antall=n()) %>%
  filter(antall>1)


names(syss)




syss %>%
  left_join(annotations, on='ISCO') %>%
  mutate(remote_count = wfh_dummy*antall) -> syss_total

sum(syss_total$antall, na.rm=T)

sum(syss_total$remote_count, na.rm=T) / sum(syss_total$antall, na.rm=T)


syss_total %>%
  filter(is.na(wfh)) %>%
  summarise(sum(antall))



ass_c <- c('0'='Armed forces and unspecified',
           '1'='Managers',
           '2'='Academics',
           '3'='Technicians and associate professionals',
           '4'='clerical support workers',
           '5'= 'Service and sales workers',
           '6'='Skilled agricultural, forestry and fishery workers',
           '7'='Craft and related trades workers',
           '8'='Plant and machine operators and assemblers',
           '9'='Elementary Occupations')












