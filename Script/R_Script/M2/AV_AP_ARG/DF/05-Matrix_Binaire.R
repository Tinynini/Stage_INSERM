#library(tidyverse)

###########################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                                    #
# Utilite == generer des matrices binaires d absence/presence GenexNiveau #
# Input == sliced_all_species_taxo.tsv                                    #
# Output == 6 fichiers Sliced_matrix_'level_name[i]'.tsv                  #
###########################################################################

#### Ouverture de sliced_all_species_taxo.tsv & recuperation des donnees dans une dataframe ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/AV_AP_ARG/DF/Dataframe/sliced_all_species_taxo.tsv', col_types = "cccccccc") %>% 
  as.data.frame() 

#### Pretraitement des donnees en vue de la creation de matrices d absence/presence GenexNiveau ####
level <- as.data.frame(all_species[, c(3:8)]) # On extrait le contenu des colonnes associees aux 6 niveaux taxonomiques etudies
level_name <- unlist(colnames(all_species[, c(3:8)])) # On extrait aussi leurs labels pour pouvoir travailler a un niveau donne plus facilement

uni_gene <- sort(unique(all_species$qseqid)) # On extrait la colonne des genes
n_gene <- length(uni_gene) 

for (i in 1:6) # Permet de parcourir les 6 niveaux taxonomiques etudies (d espece a phylum)
{
  uni_level <- as.data.frame(sort(unique(level[, i]))) # On extrait la colonne du niveau i 
  colnames(uni_level) <- level_name[i] 
  n_level <- nrow(uni_level) 
  
  #### Creaction d une matrice binaire (0/1) d absence/presence des genes au niveau i ####
  gene_matrix <- matrix(data = 0, nrow = n_gene, ncol = n_level) 
  rownames(gene_matrix) <- uni_gene 
  colnames(gene_matrix) <- uni_level[, 1]  
  
  all_species %>% # On selectionne les colonnes du niveau i et des genes
    select(qseqid, level_name[i]) %>% 
    identity() -> gene_level
  
  for (j in 1:n_gene) # Permet de parcourir les j genes distincts
  {
    curr_gene <- uni_gene[j] # Pour le gene j
    curr_level <- gene_level[gene_level$qseqid == curr_gene, level_name[i]] # Au niveau i
    
    to_set <- which(uni_level[, level_name[i]] %in% curr_level) # On extrait les representants du niveau i qui matchent le gene j
    gene_matrix[j, to_set] <- 1 # On attribue la valeur 1 aux cases associees a ces matchs dans la matrice                    
  }
  
  #### Enregistrement de la matrice binaire ainsi obtenue dans un fichier nominatif ####
  path_start <- "W:/ninon-species/output/Output_M2/AV_AP_ARG/DF/Matrice/Sliced_Matrix_"
  path_end <- ".tsv" 
  file_name <- str_glue("{path_start}{level_name[i]}{path_end}") # Le nom de fichier est definit par une variable
  write.table(gene_matrix, file_name, sep = '\t', row.names = FALSE, col.names = TRUE)
}
