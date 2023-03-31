library(tidyverse)

#### Ouverture de Sliced_ARG_Species.tsv & recuperation des donnees dans une dataframe ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_ARG_Species.tsv') %>% 
  as.data.frame() 

#### Pretraitement des donnees en vue de la creation de matrices d absence/presence ARGxLevel ####
level <- as.data.frame(all_species[, c(7:12)]) # On extrait le contenu des colonnes associees aux 6 niveaux taxonomiques etudies
level_name <- unlist(colnames(all_species[, c(7:12)])) # On extrait aussi leurs labels pour pouvoir travailler a un niveau donne plus facilement

uni_ARG <- sort(unique(all_species$qseqid)) # On extrait la colonne des ARGs
n_ARG <- length(uni_ARG) 

for (i in 1:6) # Permet de parcourir les 6 niveaux taxonomiques etudies (d espece a phylum)
{
  uni_level <- as.data.frame(sort(unique(level[, i]))) # On extrait la colonne du niveau i 
  colnames(uni_level) <- level_name[i] 
  n_level <- nrow(uni_level) 
  
  #### Creaction d une matrice binaire (0/1) d absence/presence des genes de resistances au niveau i ####
  ARG_matrix <- matrix(data = 0, nrow = n_ARG, ncol = n_level) 
  rownames(ARG_matrix) <- uni_ARG 
  colnames(ARG_matrix) <- uni_level[, 1]  
  
  all_species %>% # On selectionne les colonnes du niveau i et des ARGs
    select(qseqid, level_name[i]) %>% 
    identity() -> arg_level
  
  for (j in 1:n_ARG) # Permet de parcourir les j ARGs distincts
  {
    curr_ARG <- uni_ARG[j] # Pour l ARG j
    curr_level <- arg_level[arg_level$qseqid == curr_ARG, level_name[i]] # Au niveau i
    
    to_set <- which(uni_level[, level_name[i]] %in% curr_level) # On extrait les representants du niveau i qui matchent l ARG j
    ARG_matrix[j, to_set] <- 1 # On attribue la valeur 1 aux cases associees a ces matchs dans la matrice                    
  }
  
  #### Enregistrement de la matrice binaire ainsi obtenue dans un fichier nominatif ####
  path_start = "W:/ninon-species/output/Output_M2/ARG/Matrice/Sliced_Matrix_" 
  path_end = ".tsv" 
  file_name = str_glue("{path_start}{level_name[i]}{path_end}") # Le nom de fichier est definit par une variable
  
  write.table(ARG_matrix, file_name, sep = '\t', row.names = FALSE, col.names = TRUE) 
}
