library(tidyverse)

##################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                           #
# Utilite == ajouter la colonne des partages en format matriciel #
# Input == matrix.tsv                                            #
# Output == sliced_all_species_clust.tsv                         #
##################################################################

#### Ouverture de matrix.tsv & recuperation des donnees dans des dataframes ####
matrix <- read.csv('W:/ninon-species/data/matrix_ninon/full_matrix.tsv', header = TRUE, sep = ",")

keep_col <- rep(FALSE, ncol(matrix))
keep_col[1] <- TRUE

for (i in 2:ncol(matrix))
{
  keep_col[i] <- sum(matrix[,i]) == 0
}

matrix <- matrix[ ,keep_col]

species <- as.data.frame(sort(colnames(matrix[- 1])))

matrix %>%
  relocate(all_of(species), .after = SPECIES) %>%
  identity() -> matrix

for (l in length(species)) # Inversion des 2 parties de nom d'espece pour les especes 'UNVERIFIED_ORG' pour avoir la bonne nomenclature
{
  if (startsWith(species[l], 'UNV') == TRUE)
  {
    species[l] <- str_replace(species[l], pattern = "(.*)_(.*)_(.*)", replacement = "\\3\\_\\1\\_\\2.")
  }
}

colnames(matrix) <- c('qseqid', species)

# #### Enregistrement de la dataframe dans le fichier sliced_all_species_clust.tsv ####
write.table(all_species, "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/sliced_all_species_clust.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)
