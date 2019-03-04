#===============================================================================
# Parsing through the sample information
# 
# Tyler Bradley
# 2019-03-03 
#===============================================================================

library(tidyverse)

dw_biofilm_ids <- read_rds("data/dw_biofilm_ids.rds")
sample_info <- read_rds("data/sample-info.rds")
proj_info <- read_rds("data/proj-info.rds")

grouped_sam <- sample_info %>% 
  group_by(sra_id, name) %>% 
  nest()

all_singles <- grouped_sam %>% 
  group_by(name) %>% 
  mutate(
    count_1 = map_lgl(data, ~nrow(.x) == 1), 
    count_not_null = map_lgl(data, ~!is.null(.x))
  ) %>% 
  summarise(
    sum_count_one = sum(count_1), 
    sum_not_null = sum(count_not_null)
  ) %>% 
  filter(sum_count_one == sum_not_null) %>% 
  pull(name)

grouped_sam %>% 
  spread(key = name, value = data) %>% 
  mutate_at(vars(!!!rlang::syms(all_singles)), list(~map(., ~.x$value))) %>% 
  mutate_all(list(~map(., ~ifelse(is.null(.x), NA_character_, .x)))) %>% 
  unnest(!!!rlang::syms(c("sra_id", all_singles)), .drop = FALSE)
