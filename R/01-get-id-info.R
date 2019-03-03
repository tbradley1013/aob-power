#===============================================================================
# Read in info on all the NCBI ids from the 00-get-entrez-ids script
# 
# Tyler Bradley
# 2019-03-03 
#===============================================================================

library(tidyverse)
library(rentrez)
library(xml2)

dw_biofilm_ids <- read_rds("data/dw_biofilm_ids.rds")

proj_ids <- unique(dw_biofilm_ids$bioproject_id)

proj_info <- map_dfr(proj_ids, ~{
  entrez_summary(db = "bioproject", id = .x) %>% 
    as.data.frame() %>% 
    mutate_all(as.character)
})

temp <- entrez_fetch(db = "sra", id = dw_biofilm_ids$sra_id[1], rettype = "xml")

temp %>% 
  read_xml() %>% 
  xml_find_all(temp, ".//EXPERIMENT_PACKAGE")
