library(tidyverse)

#### Ouverture de all_species_clust.tsv et de Matrix.tsv (ou de Sliced_all_species_clust.tsv et de New_Matrix.tsv) & recuperation des donnees ####
matrix <- read_tsv('W:/ninon-species/output/Output_M1/Matrice/Matrix.tsv')
#matrix <- read_tsv('W:/ninon-species/output/Output_M1/Matrice/New_Matrix.tsv') 

all_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/all_species_clust.tsv') %>% 
#all_species <- read_tsv('W:/ninon-species/output/Output_M1/Dataframe/sliced_all_species_clust.tsv') %>% 
  as.data.frame()

matrix <- as.matrix(matrix)

gene <- sort(unique(all_species$qseqid))
rownames(matrix) <- gene

#### Exemple des barplots d absence/presence que l on obtient pour un ARG de la famille des 'aph' (aph(3')-XV) ####
barplot(matrix[258,], main = "Partage inter-espèces de aph(3')", axisnames = FALSE)
#barplot(matrix[121,], main = "Partage inter-espèces de aph(3')") # Version reduite

# La on ne conserve que les presences pour pouvoir voir les nom d'especes se partageant l'ARG (avec le zoom en plein ecran ou en etirant suffisement la zone de plot)
to_set <- which(matrix[258,] != 0)
#to_set <- which(matrix[121,] != 0) # Version reduite
m <- matrix[258, c(to_set)]
#m <- matrix[121, c(to_set)] # Version reduite
barplot(m, main = "Partage inter-espèces de aph(3')")

#### Exemple de calcul des distances et du plot du dendrogramme associe pour la famille des 'aph' ####
aph_ARG <- matrix
j <- 1

for (i in 1:nrow(matrix)) 
{
  if (startsWith(gene[i], 'aph') != TRUE)
  {
    aph_ARG <- aph_ARG[-j,]
  }
  else
  {
    j <- j + 1
  }
}

all_dist <- dist(aph_ARG, method = 'binary')

clust <- hclust(all_dist, "complete")
plot(clust)