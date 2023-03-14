library(tidyverse)

#### Ouverture de all_species_clust.tsv (ou de Sliced_all_species_clust.tsv) & recuperation des donnees dans une dataframe ####
all_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/all_species_clust.tsv') %>% 
#all_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/sliced_all_species_clust.tsv') %>% 
  as.data.frame()

#### Pretraitement des donnees en vue de la creation d une matrice d absence/presence ARGxEspece ####
uni_ARG <- sort(unique(all_species$qseqid))
n_ARG <- length(uni_ARG)

uni_species <- sort(unique(all_species$species))
n_species <- length(uni_species)

all_species %>% 
  select(qseqid, species) %>% 
  identity() -> arg_species

#### Creaction d une matrice binaire (0/1) d absence/presence des genes de resistances au niveau des especes ####
all_matrix <- matrix(data = 0, nrow = n_ARG, ncol = n_species)
rownames(all_matrix) <- uni_ARG
colnames(all_matrix) <- uni_species

for (i in 1:n_ARG) 
{
  curr_ARG <- uni_ARG[i]
  curr_species <- arg_species[arg_species$qseqid == curr_ARG, 'species']
  to_set <- which(uni_species %in% curr_species)
  all_matrix[i, to_set] <- 1
}

#### Enregistrement de la matrice complete dans le fichier Matrix.tsv (ou de celle reduite dans le fichier New_Matrix.tsv) ####
write.table(all_matrix, "W:/ninon-species/output/Output_M1/Matrice/Matrix.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
#write.table(all_matrix, "W:/ninon-species/output/Output_M1/Matrice/New_Matrix.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
