#library(tidyverse)

##########################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                   #
# Utilite == nettoyer la matrice et extraire les especes #
# Input == matrix.tsv                                    #
# Output == sliced_all_species_clust.tsv et species.tsv  #
##########################################################

#### Ouverture de matrix.tsv & recuperation des donnees dans des dataframes ####
matrix <- read.csv('W:/ninon-species/data/matrix_ninon/100K_matrix.tsv', header = TRUE, sep = ",")

keep_col <- rep(FALSE, ncol(matrix))

keep_col[1] <- TRUE

for (i in 2:ncol(matrix))
{
  keep_col[i] <- sum(matrix[,i]) > 0
}

matrix <- matrix[ ,keep_col]

species <- sort(colnames(matrix[- 1]))

matrix %>%
  relocate(all_of(species), .after = SPECIES) %>%
  identity() -> matrix

species <- as.data.frame(species)

for (l in nrow(species)) # Inversion des 2 parties de nom d'espece pour les especes 'UNVERIFIED_ORG' pour avoir la bonne nomenclature
{
  if (startsWith(species[l,], 'UNV') == TRUE)
  {
    species[l,] <- str_replace(species[l,], pattern = "(.*)_(.*)_(.*)", replacement = "\\3\\_\\1\\_\\2.")
  }
}

colnames(matrix) <- c('qseqid', species[, 1])

#### Enregistrement de la dataframe dans le fichier sliced_all_species_clust.tsv ####
write.table(matrix, "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/sliced_all_species_clust.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
write.table(species, "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
