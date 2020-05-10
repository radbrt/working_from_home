wfh %>% 
  mutate(ISCO2 = substr(ISCO, 1, 2)) %>% 
  inner_join(syss_total, by = 'ISCO') %>% 
  group_by(ISCO2) %>% 
  summarise(ant_total = sum(antall), ant_remote = sum(remote_count)) -> wfh_ISCO2

nber %>%
  inner_join(wfh_ISCO2, by='ISCO2') %>% 
  mutate(remote_share = ant_remote/ant_total) %>% 
  group_by(ref_area, ref_area.label, time) %>% 
  summarize(total_remote_count_k = sum(obs_value*remote_share, na.rm=T),
            total_remote_share = sum(obs_value*remote_share, na.rm=T)/sum(obs_value, na.rm=T)) -> dingel_remade


# Sjekker at data er i antall 1000.
nber %>% 
  filter(ref_area=='NOR') %>% 
  group_by(time) %>% 
  summarize(ant = sum(obs_value))