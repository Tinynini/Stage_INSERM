library(tidyverse)

#### Ouverture de all_species_clust.tsv et de M_Genus_ARG.tsv (ou de Sliced_all_species_clust.tsv et de New_M_Genus_ARG.tsv) & recuperation des donnees ####
Genus_matrix <- read_tsv('W:/ninon-species/output/M_Genus_ARG.tsv') 
#Genus_matrix <- read_tsv('W:/ninon-species/output/New_M_Genus_ARG.tsv') 

all_species <- read_tsv('W:/ninon-species/output/all_species_clust.tsv') %>% 
#all_species <- read_tsv('W:/ninon-species/output/sliced_all_species_clust.tsv') %>% 
  as.data.frame()

Genus_matrix <- as.matrix(Genus_matrix)

gene <- sort(unique(all_species$qseqid))
rownames(Genus_matrix) <- gene

#### Exemple des barplots d absence/presence que l on obtient pour un ARG de la famille des 'aph' (aph(3')-XV) ####
barplot(Genus_matrix[258,], main = "Partage inter-génus de aph(3')", axisnames = FALSE) 
#barplot(Genus_matrix[121,], main = "Partage inter-génus de aph(3')") # Version réduite 

# La, on ne conserve que les presences pour pouvoir voir les nom de genus se partageant l'ARG (avec le zoom en plein ecran ou en etirant suffisement la zone de plot)
to_set <- which(Genus_matrix[258,] != 0)
#to_set <- which(Genus_matrix[121,] != 0) # Version reduite
m <- Genus_matrix[258, c(to_set)]
#m <- Genus_matrix[121, c(to_set)] # Version reduite
barplot(m, main = "Partage inter-génus de aph(3')")

#### Exemple de calcul des distances et du plot du dendrogramme associe pour la famille des 'aph' ####
aph_ARG <- Genus_matrix
j <- 1

for (i in 1:nrow(Genus_matrix)) 
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
