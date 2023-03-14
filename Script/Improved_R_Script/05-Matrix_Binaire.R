library(tidyverse)

all_species <- read_tsv('W:/ninon-species/output/Dataframe/Dataframe_M2/Sliced_ARG_Species.tsv') %>% 
  as.data.frame()

level <- as.data.frame(all_species[, c(7:12)])
level_name <- unlist(colnames(all_species[, c(7:12)]))

uni_centro <- sort(unique(all_species$Centroid))
n_centro <- length(uni_centro)

for (i in 1:6)
{
  uni_level <- as.data.frame(sort(unique(level[, i])))
  colnames(uni_level) <- level_name[i]
  n_level <- nrow(uni_level)

  centro_matrix <- matrix(data = 0, nrow = n_centro, ncol = n_level)
  rownames(centro_matrix) <- uni_centro
  colnames(centro_matrix) <- uni_level[, 1]
  
  all_species %>% 
    select(Centroid, level_name[i]) %>% 
    identity() -> arg_level
   
  for (j in 1:n_centro)
  {
    curr_centro <- uni_centro[j]
    curr_level <- arg_level[arg_level$Centroid == curr_centro, level_name[i]]
    
    to_set <- which(uni_level[, level_name[i]] %in% curr_level)
    centro_matrix[j, to_set] <- 1                       
  }

  path_start = "W:/ninon-species/output/Matrice/Matrice_M2/Sliced_Matrix_"
  path_end = ".tsv"
  file_name = str_glue("{path_start}{level_name[i]}{path_end}")

  write.table(centro_matrix, file_name, sep = '\t', row.names = FALSE, col.names = TRUE)
}
