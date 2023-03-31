library(tidyverse)

#### Ouverture de Sliced_ARG_Species.tsv & recuperation des donnees ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_ARG_species.tsv') %>% 
  as.data.frame() 

uni_centro <- sort(unique(all_species$Centroid)) # On extrait la colonne des centroid 

#### Obtention de la liste des fichiers contenant nos matrices binaires et pseudo-binaires ####
# On se rend dans le bon emplacement puis on recherche la parterne de nom de fichier 'Sliced_Matrix_.*.tsv' qui est commune aux 2 types de matrice 
all_matrix <- list.files(path = 'W:/ninon-species/output/Output_M2/ARG/Matrice', pattern = 'Sliced_Matrix_.*.tsv', full.names = TRUE) 
n_matrix <- length(all_matrix) # On recupere le nombre de fichier contenus dans notre liste de fichier 

matrix_name <- str_replace(all_matrix, '(.*)(Matrix)_(.*).(tsv)', '\\3') # On recupere les noms de matrices a partir des noms de fichiers 

for (i in 1:n_matrix) # Permet de parcourir les matrices une par une
{
  centro_matrix <- read_tsv(file = all_matrix[i]) # On ouvre la matrice depuis la liste de fichier
  centro_matrix <- as.matrix(centro_matrix) 
  rownames(centro_matrix) <- uni_centro 
  
  #### Barplot de la presence d un ARG donne (ici aac(6')-31_1_AM283489) ####
  debut = "Partage inter-" 
  fin = " de " 
  start = " inter-" 
  end = " sharing" 
  
  if (grepl('(.*)_(.*)', matrix_name[i]) == TRUE) # On ne fait ce plot que pour les matrices pseudo-binaires
  { # N.B. : Il suffit de changer l index dans centro_matrix et uni_centro pour tester un autre ARG
    to_set <- which(centro_matrix[36,] != 0) # On isole les colonnes pour lesquels l ARG matche
    m <- centro_matrix[36, c(to_set)] # On extrait lesdites colonnes
    barplot(m, main = str_glue("{debut}{matrix_name[i]}{fin}{uni_centro[36]}")) # Barblot de la presence de l ARG donne dans la matrice
    barplot(m, main = str_glue("{uni_centro[36]}{start}{matrix_name[i]}{end}")) # Barblot de la presence de l ARG donne dans la matrice
  }
  
  #### Meme chose mais avec l ensemble des ARG en meme temps (mais ca ne marche pas donc est qu on garde ca ??) #### 
  # to_set2 <- which(centro_matrix != 0) # Ne peut pas etre applique directement a l ensemble de la matrice
  # m2 <- centro_matrix[, c(to_set2)]
  # barplot(centro_matrix, main = str_glue("{debut}{matrix_name[i]}"))
  # barplot(centro_matrix, main = str_glue("{start}{matrix_name[i]}{end}"))
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
  # centro_matrix <- as.data.frame(centro_matrix)
  # plot <- ggplot(centro_matrix) + geom_histogram(bins = max) # Ne marche pas pour des raisons qui m echape
  # plot + ggtitle(str_glue("{debut}{matrix_name[i]}")) + xlab("??") + ylab("Partage")
  # plot + ggtitle(str_glue("{start}{matrix_name[i]}{end}")) + xlab("??") + ylab("Sharing")
  
  #### Dendogramme d une famille d ARG (celle de l ARG teste ci-avant tant qu a faire) ####
  ARG_family <- centro_matrix # Preparation d une nouvelle matrice qu on va rendre specifique a une famille d ARG
  j <- 1

  for (m in 1:nrow(centro_matrix)) # Permet de parcourir la matrice ligne par ligne
  {
    if (startsWith(uni_centro[m], 'aac') != TRUE) # Si la ligne m ne correspond pas a un ARG de la famille voulue (ici celle des 'aac')
    { # N.B. : Il suffit de changer la paterne recherchee dans startsWith() pour tester une autre famille
      ARG_family <- ARG_family[-j,] # On supprime la ligne de notre nouvelle matrice
    }
    else # Sinon
    {
      j <- j + 1 # On passe directement a la ligne suivante
    }
  }

  all_dist <- dist(ARG_family, method = 'binary') # On calcule les distances au sein de notre nouvelle matrice
  clust <- hclust(all_dist, "complete") # On clusterise ses distances
  plot(clust) # On plot le dendogramme resultant
}
