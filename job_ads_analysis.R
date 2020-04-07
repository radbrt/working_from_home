library(tidyverse)
library(arrow)

df <- read_parquet('data/stillinger_all_merged_isco08.parquet')


head(df)
min(df$statistikk_aar_mnd)

