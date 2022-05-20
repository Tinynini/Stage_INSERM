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

#### Exemple des barplots d'absence/présence que l'on obtient pour un ARG de la famille des 'aad' ####
barplot(matrix[100,], axisnames = FALSE)
#barplot(matrix[68,])

# Là, on ne conserve que les présences pour pouvoir voir les nom d'espèces se partageant l'ARG (avec le zoom en plein écran ou en étirant suffisement la zone de plot)
to_set <- which(matrix[100,] != 0)
#to_set <- which(matrix[68,] != 0)
m <- matrix[100, c(to_set)]
#m <- matrix[68, c(to_set)]
barplot(m)

#### Exemple de calcul des distances et du plot du dendrogramme associé pour la famille des 'aad' ####
aad_ARG <- matrix
j <- 1

for (i in 1:nrow(matrix)) 
{
  if (startsWith(gene[i], 'aad') != TRUE)
  {
    aad_ARG <- aad_ARG[-j,]
  }
  else
  {
    j <- j + 1
  }
}

all_dist <- dist(aad_ARG, method = 'binary')

clust <- hclust(all_dist, "complete")
plot(clust, labels = FALSE)