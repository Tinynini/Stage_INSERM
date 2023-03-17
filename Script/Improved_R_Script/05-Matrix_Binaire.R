library(tidyverse)

#### Ouverture de Sliced_all_species_clust.tsv & recuperation des donnees dans une dataframe ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_ARG_Species.tsv') %>% 
  as.data.frame() # On ouvre le fichier sous la forme d une dataframe

#### Pretraitement des donnees en vue de la creation de matrices d absence/presence ARGxLevel ####
level <- as.data.frame(all_species[, c(7:12)]) # On extrait le contenu des colonnes associes aux 6 niveaux taxonomiques etudies
level_name <- unlist(colnames(all_species[, c(7:12)])) # On extrait aussi leurs labels pour pouvoir travailler a un niveau donne plus facilement

uni_centro <- sort(unique(all_species$Centroid)) # On extrait la colonne des centroid en appliquant sort(unique()) dessus pour les trier en les dedoublonnant 
n_centro <- length(uni_centro) # On recupere le nombre de centroids distincts

for (i in 1:6) # Permet de parcourir les 6 niveaux taxonomiques etudies (d espece a phylum)
{
  uni_level <- as.data.frame(sort(unique(level[, i])))# On extrait la colonne du niveau i en appliquant sort(unique()) dessus pour le trier en le dedoublonnant 
  colnames(uni_level) <- level_name[i] # On renomme la colonne extraite pour faciliter son utilisation a venir
  n_level <- nrow(uni_level) # On recupere le nombre de representant distints du niveau i
  
  #### Creaction d une matrice binaire (0/1) d absence/presence des genes de resistances au niveau traite ####
  centro_matrix <- matrix(data = 0, nrow = n_centro, ncol = n_level) # Dimensionnee selon les 2 valeurs recuperee precedemment & remplie de 0 pour l instant
  rownames(centro_matrix) <- uni_centro # On associe les noms de centroids aux lignes
  colnames(centro_matrix) <- uni_level[, 1] # Et ceux des representant du niveau i aux colonne 
  # N.B. : On aurait tres bien pu faire le contraire c est kif-kif
  all_species %>% 
    select(Centroid, level_name[i]) %>% # On selectionne les colonnes du niveau i et des centroids
    identity() -> arg_level
  
  for (j in 1:n_centro) # Permet de parcourir les j centroids distincts
  {
    curr_centro <- uni_centro[j] # Pour le centroid j
    curr_level <- arg_level[arg_level$Centroid == curr_centro, level_name[i]] # Au niveau i
    
    to_set <- which(uni_level[, level_name[i]] %in% curr_level) # On extrait les representant du niveau i qui matchent le centroid j
    centro_matrix[j, to_set] <- 1 # On attribue la valeur 1 aux cases associees a ces matchs dans la matrice                    
  }
  
  #### Enregistrement de la matrice complete dans un fichier nominatif ####
  path_start = "W:/ninon-species/output/Output_M2/ARG/Matrice/Sliced_Matrix_" # Chemin d acces + debut de nom de fichier
  path_end = ".tsv" # Fin de nom de fichier (== extension du fichier)
  file_name = str_glue("{path_start}{level_name[i]}{path_end}") # Assemblage des 2 autour du label du niveau i pour obtenir le nom de fichier complet
  
  write.table(centro_matrix, file_name, sep = '\t', row.names = FALSE, col.names = TRUE) # Process habituel d enregistrement d une structure de type table dans un fichier
}
