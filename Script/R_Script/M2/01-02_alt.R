library(tidyverse)

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

gene <- matrix[, 1]
sharing <- matrix[, -1] 

all_species <- as.data.frame(matrix(data="0", nrow=1, ncol=3))
colnames(all_species) <- c('qseqid', 'shared_by', 'species')

for (i in 1:length(gene))
{
  
  share <- sum(sharing[i,])
  
  if (share > 0) # uniquement necessaire avec la matrice de test
  {
    gene_species_share <- as.data.frame(matrix(data="0", nrow=share, ncol=3))
    colnames(gene_species_share) <- c('qseqid', 'shared_by', 'species')
    
    k <- 0
    
    for (j in 1:length(species))
    {
      if (sharing[i, j] == 1)
      {
        k <- k + 1
        gene_species_share[k, c('qseqid', 'shared_by', 'species')] <- c(gene[i], share, species[j])
      }
    }
    
    all_species <- rbind(all_species, gene_species_share)
  }
}

all_species <- all_species[-1,]

#### Enregistrement de la dataframe dans le fichier sliced_all_species_clust.tsv ####
write.table(all_species, "W:/ninon-species/output/Output_M2/AV_AP_ARG/Dataframe/sliced_all_species_clust.tsv", sep = '\t', row.names = FALSE, col.names = TRUE)