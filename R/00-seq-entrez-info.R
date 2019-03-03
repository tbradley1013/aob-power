#===============================================================================
# 
# 
# Tyler Bradley
# 2019-02-24 
#===============================================================================

library(rentrez)
library(tidyverse)

dw_biofilm_sra <- entrez_search(
  "sra", 
  term = "biofilm metagenome[ORGN] AND drinking water", 
  retmax = 1000
)

entrez_link_safe <- possibly(entrez_link, otherwise = NULL)

dw_biofilm_ids <- map_dfr(dw_biofilm_sra$ids, ~{
  bp_link <- entrez_link(dbfrom = "sra", id = .x, db = "bioproject")
  if (!is.null(bp_link)){
    bp_id <- bp_link$links$sra_bioproject
  } else bp_id <- NA_character_
  
  
  output <- tibble(
    sra_id = .x,
    bioproject_id = bp_id
  )
  
  return(output)
})


write_rds(dw_biofilm_ids, "~/Desktop/dw_biofilm_ids.rds")
