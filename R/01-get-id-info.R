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

fetch_safe <- possibly(entrez_fetch, otherwise = NULL)

sample_info <- map_dfr(dw_biofilm_ids$sra_id, function(z){
  fetch_data <- fetch_safe(db = "sra", id = z, rettype = "xml") 
  
  if (is.null(fetch_data)) return(NULL)
  
  output <- fetch_data %>% 
    read_xml() %>% 
    xml_find_all(".//EXPERIMENT_PACKAGE") %>% 
    xml_children() %>% 
    map(xml_children) %>% 
    flatten() %>% 
    map_dfr(~{
      tibble(
        parent_name = xml_parent(.x) %>% xml_name(),
        # parent_value = xml_parent(.x) %>% xml_text(),
        name = xml_name(.x),
        value = xml_text(.x)
      )
    })
  
  output <- output %>% 
    mutate(sra_id = z) %>% 
    select(sra_id, everything())
})

beepr::beep(8)


write_rds(proj_info, "data/proj-info.rds", compress = "gz")
write_rds(sample_info, "data/sample-info.rds", compress = "gz")
