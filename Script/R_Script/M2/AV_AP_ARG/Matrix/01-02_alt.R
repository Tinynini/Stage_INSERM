#library(tidyverse)

##########################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                   #
# Utilite == nettoyer la matrice et extraire les especes #
# Input == t_full_matrix.tsv                             #
# Output == sliced_all_species_clust.tsv et species.tsv  #
##########################################################

#### Ouverture de matrix.tsv & recuperation des donnees dans des dataframes ####
matrix <- read.csv('W:/ninon-species/data/matrix_ninon/100K_matrix.tsv', header = TRUE, sep = ",")
#matrix <- read.csv('W:/ninon-species/data/matrix_ninon/t_full_matrix.tsv', header = TRUE, sep = ",")

# LA TRANSPOSITION SERA FAITE EN AMONT PLUS TARD
rownames(matrix) <- matrix[, 1]
matrix <- matrix[, -1]

matrix <- t(as.matrix(matrix))
# FIN TRANSPOSITION

keep_row <- rep(FALSE, nrow(matrix))

for (i in 1:nrow(matrix))
{
  keep_row[i] <- sum(matrix[i,]) > 0
}

matrix <- matrix[keep_row,]

species <- as.data.frame(sort(rownames(matrix)))
colnames(species) <- 'species'

matrix <- as.data.frame(matrix)

matrix %>%
  mutate(species = rownames(matrix), .before = matrix[, 1]) %>%
  arrange(species) %>%
  identity() -> matrix

for (l in nrow(species)) # Inversion des 2 parties de nom d'espece pour les especes 'UNVERIFIED_ORG' pour avoir la bonne nomenclature
{
  if (startsWith(species[l,], 'UNV') == TRUE)
  {
    species[l,] <- str_replace(species[l,], pattern = "(.*)_(.*)_(.*)", replacement = "\\3\\_\\1\\_\\2.")
  }
}

matrix[, 1] <- species[, 1]

#### Enregistrement de la dataframe dans le fichier sliced_all_species_clust.tsv ####
write.table(matrix, "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/sliced_all_species_clust.tsv", sep = '\t', row.names = TRUE, col.names = TRUE)
write.table(species, "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/species.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
