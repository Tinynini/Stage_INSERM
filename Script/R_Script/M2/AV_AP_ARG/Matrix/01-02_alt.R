#library(tidyverse)

########################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                                 #
# Utilite == obtenir la dataframe slicee a partir de la matrice slicee #
# Input == matrix.tsv                                                  #
# Output == sliced_all_species_clust.tsv                               #
########################################################################

#### Ouverture de matrix.tsv & recuperation des donnees dans des dataframes ####
matrix <- read.csv('W:/ninon-species/data/vib_matrix.tsv', header = TRUE, sep = ",")

species <- colnames(matrix)
species <- species[-1]

for (l in length(species)) # Inversion des 2 parties de nom d'espece pour les especes 'UNVERIFIED_ORG' pour avoir la bonne nomenclature
{
  if (startsWith(species[l], 'UNV') == TRUE)
  {
    species[l] <- str_replace(species[l], pattern = "(.*)_(.*)_(.*)", replacement = "\\3\\_\\1\\_\\2.")
  }
}

colnames(matrix) <- c('qseqid', species)

sharing <- matrix[, -1] 
all_species <- as.data.frame(matrix(data="0", nrow=1, ncol=(ncol(matrix) + 1)))
colnames(all_species) <- c('qseqid', 'shared_by', species)

for (i in 1:nrow(matrix))
{
  share <- sum(sharing[i,])
  
  if (share > 0) # uniquement necessaire avec la matrice de test
  {
    gene_species_share <- cbind(matrix[i, 1], share, sharing[i,])
    colnames(gene_species_share) <- c('qseqid', 'shared_by', species)
  
    all_species <- rbind(all_species, gene_species_share)
  }
}

all_species <- all_species[-1,]

#### Enregistrement de la dataframe dans le fichier sliced_all_species_clust.tsv ####
write.table(all_species, "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/sliced_all_species_clust.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
