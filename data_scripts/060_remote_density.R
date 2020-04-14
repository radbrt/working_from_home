source("data_scripts/000_includes.R")

load("workdata/syss_total_komm.RData")

areas <- read_csv('data/muni_density.csv')

names(areas) <- c('region', 'befolkning', 'areal', 'landareal', 'density')

areas <- areas %>% 
  filter(str_detect(substr(region, 1, 4), '[0-9]{4}')==TRUE)

areas_isco <- areas %>% 
  filter(str_detect(substr(region, 1, 4), '[0-9]{4}')==TRUE) %>% 
  mutate(kommnr = substr(region, 1, 4)) %>% 
  inner_join(syss_total_komm, by=c('kommnr')) 

save(areas_isco, file="workdata/areas_isco.RData")