library(tidyverse)

#### Ouverture de all_species_clust.tsv et de Matrix.tsv (ou de Sliced_all_species_clust.tsv et de New_Matrix.tsv) & recuperation des donnees ####
matrix <- read_tsv('W:/ninon-species/output/Output_M1/Matrice/Matrix.tsv') 
#matrix <- read_tsv('W:/ninon-species/output/Output_M1/Matrice/New_Matrix.tsv') 

all_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/all_species_clust.tsv') %>% 
#all_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/sliced_all_species_clust.tsv') %>% 
  as.data.frame()

uni_ARG <- sort(unique(all_species$qseqid))
rownames(matrix) <- uni_ARG
matrix <- as.matrix(matrix)

#### Pretraitement des donnees en vue de la creation d une matrice d absence/presence ARGxGenus ####
genus <- str_replace(colnames(matrix), pattern = '(.*)_(.*)', replacement = "\\1")
gene <- str_replace(rownames(matrix), pattern = '(.*)_(.*)_(.*)', replacement = "\\1")
genu <- unique(genus)

colnames(matrix) <- genus
rownames(matrix) <- gene

#### Creaction d'une matrice pseudo-binaire (0/1~n) d absence/presence des genes de resistances au niveau des genus ####
Genus_ARG <- matrix(data = 0, nrow = length(uni_ARG), ncol = length(genu))

colnames(Genus_ARG) <- genu
rownames(Genus_ARG) <- gene
rownames(Genus_ARG) <- uni_ARG

l_1 <- length(genu)

for (i in 1:l_1)
{
  to_set <- which(genus %in% genu[i])
  l_2 <- length(to_set)
  m <- matrix[, c(to_set)]
  
  if (l_2 > 1) 
  {
    Genus_ARG[,i] <- rowSums(m)
  }
  else
  {
    Genus_ARG[,i] <- m
  }
}

#### Enregistrement de la matrice complete dans le fichier M_Genus_ARG.tsv (ou de celle reduite dans le fichier New_M_Genus_ARG.tsv) ####
write.table(Genus_ARG, "W:/ninon-species/output/Output_M1/Matrice/M_Genus_ARG.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
#write.table(Genus_ARG, "W:/ninon-species/output/Output_M1/Matrice/New_M_Genus_ARG.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)