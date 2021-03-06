library(tidyverse)

#### Ouverture de all_species_clust.tsv et de Matrix.tsv (ou de Sliced_all_species_clust.tsv et de New_Matrix.tsv) & récupération des données ####
matrix <- read_tsv('W:/ninon-species/output/Matrix.tsv')
#matrix <- read_tsv('W:/ninon-species/output/New_Matrix.tsv') 

all_species <- read_tsv('W:/ninon-species/output/all_species_clust.tsv') %>% 
#all_species <- read_tsv('W:/ninon-species/output/sliced_all_species_clust.tsv') %>% 
  as.data.frame()

matrix <- as.matrix(matrix)

gene <- sort(str_replace(unique(all_species$qseqid), pattern = '(.*)_(.*)_(.*)', replacement = "\\1"))
rownames(matrix) <- gene

#### Exemple des barplots d'absence/présence que l'on obtient pour un ARG de la famille des 'aph' (aph(3')-XV) ####
barplot(matrix[258,], main = "Partage inter-espèces de aph(3')-XV", axisnames = FALSE)
#barplot(matrix[121,], main = "Partage inter-espèces de aph(3')-XV") # Version réduite

# Là, on ne conserve que les présences pour pouvoir voir les nom d'espèces se partageant l'ARG (avec le zoom en plein écran ou en étirant suffisement la zone de plot)
to_set <- which(matrix[258,] != 0)
#to_set <- which(matrix[121,] != 0) # Version réduite
m <- matrix[258, c(to_set)]
#m <- matrix[121, c(to_set)] # Version réduite
barplot(m, main = "Partage inter-espèces de aph(3')-XV")

#### Exemple de calcul des distances et du plot du dendrogramme associé pour la famille des 'aph' ####
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
plot(clust, labels = FALSE)
