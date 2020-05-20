source("data_scripts/000_includes.R")

load("workdata/wfh.RData")

annotations <- read_parquet('master_data/mt_data_avg.parquet')

wfh %>% 
  group_by(yrkeskode) %>% 
  summarize(antall = n()) %>% 
  filter(antall>=3) -> nonminor_ads_iscos

nonminor_iscos <- intersect(nonminor_ads_iscos$yrkeskode, annotations$ISCO)

annotations %>%
  mutate(ISCO1 = substr(ISCO,1 ,1)) %>%
  filter(ISCO %in% nonminor_iscos) -> nonminor_annotations


wfh %>%
  mutate(ISCO1 = substr(yrkeskode,1 ,1),
         antall_stillinger = as.numeric(antall_stillinger)) %>%
  mutate(antall_stillinger = replace_na(antall_stillinger, 1)) %>%
  filter(statistikk_aar_mnd>'2018' & yrkeskode %in% nonminor_iscos) %>%
  inner_join(nonminor_annotations, by="ISCO1") %>%
  group_by(ISCO1) %>%
  summarize(n_ads = sum(antall_stillinger),
            n_wfh_annotations = sum(wfh_prob*antall_stillinger),
            n_wfh_ads = sum(wfh*antall_stillinger) ) -> wfh_isco1_weighted


wfh_isco1_weighted %>%
  mutate(relative_prob_annotations = n_wfh_annotations / sum(n_wfh_annotations),
         relative_prob_ads = n_wfh_ads / sum(n_wfh_ads)) %>%
  mutate(diff = relative_prob_annotations-relative_prob_ads) -> weighted_st1_stats


save(weighted_st1_stats, file="workdata/weighted_st1_stats.RData")


weighted_st1_stats %>% 
  select(-starts_with("n_")) %>% 
  mutate(ISCO1=isco_labels[ISCO1]) %>% 
  gt() %>%
  tab_header("Relative frequency of remote-possibilities across ISCO groups") %>%
  fmt_percent(columns = vars(relative_prob_annotations, relative_prob_ads, diff), decimals = 1, dec_mark = ",") %>%
  cols_label(ISCO1 = 'Occupational group',
             relative_prob_annotations = "Annotations",
             relative_prob_ads = "Job ads",
             diff = "Difference") %>%
  tab_spanner(
    columns = vars(relative_prob_annotations, relative_prob_ads),
    label="Relative remote frequency"
  ) %>%
  as_latex()  %>% 
  as.character() %>% 
  cat




