library(tidyverse)

all_species <- read_tsv('W:/ninon-species/output/Total_ARG_species.tsv') %>% 
  #all_species <- read_tsv('W:/ninon-species/output/Sliced_ARG_species.tsv') %>% 
  as.data.frame()

uni_centro <- sort(unique(all_species$Centroid))
#gene <- sort(unique(all_species$qseqid))

all_matrix <- list.files(path = 'W:/ninon-species/output', pattern = 'Matrix_.*.tsv', full.names = TRUE)
#all_matrix <- list.files(path = 'W:/ninon-species/output', pattern = 'Sliced_Matrix_.*.tsv', full.names = TRUE)
n_matrix <- length(all_matrix)

matrix_name <- str_replace(all_matrix, '(.*)(Matrix)_(.*).(tsv)', '\\3')

for (i in 1:n_matrix)  
{
  centro_matrix <- read_tsv(file = all_matrix[i])
  centro_matrix <- as.matrix(centro_matrix)
  rownames(centro_matrix) <- uni_centro
  
  deb = "Partage inter-"
  fin = " de aac(6')-31_1_AM283489"
  titre <- str_glue("{deb}{matrix_name[i]}{fin}")
  
  barplot(centro_matrix[36,], main = titre, axisnames = FALSE)

  to_set <- which(centro_matrix[36,] != 0)
  m <- centro_matrix[36, c(to_set)]

  barplot(m, main = titre)
  hist(m, main = titre)

  #### Ou ça marche pas, ou c'est lentissimo pour espèce et génus ####
  
  # to_set2 <- which(centro_matrix != 0)
  # m2 <- centro_matrix[, c(to_set2)]
  # barplot(centro_matrix, main = titre)
  # 
  # max <- 1
  # 
  # for (k in 1:ncol(centro_matrix))
  # {
  #   if (max(centro_matrix[, k]) > max)
  #   {
  #     max <- max(centro_matrix[, k])
  #   }
  # }
  # 
  # hist(centro_matrix, breaks = max, main = titre)
  #
  # plot <- ggplot(centro_matrix) + geom_histogram(bins = max)
  # plot + ggtitle(titre) + xlab("???") + ylab("??")
  
  #### Est-ce que ça sert vraiment à quelque chose ???? ####
  
  aac_ARG <- centro_matrix 
  j <- 1

  for (i in 1:nrow(centro_matrix))
  {
    if (startsWith(uni_centro[i], 'aac') != TRUE)
    {
      aac_ARG <- aac_ARG[-j,]
    }
    else
    {
      j <- j + 1
    }
  }

  all_dist <- dist(aac_ARG, method = 'binary')

  clust <- hclust(all_dist, "complete")
  plot(clust, labels = FALSE)
}