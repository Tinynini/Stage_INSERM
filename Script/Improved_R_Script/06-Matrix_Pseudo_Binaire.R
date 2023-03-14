library(tidyverse)

all_species <- read_tsv('W:/ninon-species/output/Output_M2/Dataframe/Sliced_ARG_Species.tsv') %>% 
  as.data.frame()

level <- as.data.frame(all_species[, c(7:12)])
level_name <- unlist(colnames(all_species[, c(7:12)]))

uni_centro <- sort(unique(all_species$Centroid))
n_centro <- length(uni_centro)

for (i in 1:5)
{
  path_start = "W:/ninon-species/output/Output_M2/Matrix/Sliced_Matrix_"
  path_end = ".tsv"
  file_name = str_glue("{path_start}{level_name[i]}{path_end}")
  
  now_level <- as.data.frame(sort(unique(level[, i]))) 
  colnames(now_level) <- level_name[i]
  
  for (j in (i + 1):6)
  {
    curr_level <- as.data.frame(unique(level[, c(j, i)]))
    na_level_1 <- which(is.na(curr_level[, 1]) == TRUE)
    curr_level <- curr_level[-c(na_level_1),]
    
    if (i > 1)
    {
      na_level_2 <- which(is.na(curr_level[, 2]) == TRUE)
      curr_level <- curr_level[-c(na_level_2),]
    }
    
    curr_level %>%
      arrange_(level_name[j]) %>%
      identity() -> curr_level
    
    uni_level <- unlist(as.data.frame(sort(unique(curr_level[, 1]))))
    n_level <- length(uni_level)
    
    centro_matrix <- read_tsv(file_name)
    
    rownames(centro_matrix) <- uni_centro
    
    centro_matrix <- t(centro_matrix)
    
    centro_matrix <- cbind(now_level, centro_matrix)
    
    centro_matrix <- left_join(curr_level, centro_matrix, by = NULL)
    
    centro_matrix <- t(centro_matrix[-2])
    
    colnames(centro_matrix) <- centro_matrix[1,]
    
    centro_matrix <- as.data.frame(centro_matrix[-1,])

    for (n in 1:ncol(centro_matrix))
    {
      centro_matrix[, n] <- as.integer(c(centro_matrix[, n]))
    }

    centro_matrix <- as.matrix(centro_matrix)
    
    cross_matrix <- matrix(data = 0, nrow = n_centro, ncol = n_level)
    colnames(cross_matrix) <- uni_level
    rownames(cross_matrix) <- uni_centro

    for (k in 1:n_level)
    {
      to_set <- which(curr_level[, 1] %in% uni_level[k])
      l <- length(to_set)
      m <- centro_matrix[, c(to_set)]

      if (l > 1)
      {
        cross_matrix[, k] <- rowSums(m)
      }

      else
      {
        cross_matrix[, k] <- m
      }
    }

    path_start = "W:/ninon-species/output/Output_M2/Matrice/Sliced_Matrix_"
    path_end = ".tsv"
    new_file_name = str_glue("{path_start}{level_name[i]}_{level_name[j]}{path_end}")

    write.table(cross_matrix, new_file_name, sep = '\t', row.names = FALSE, col.names = TRUE)
  }
}
