library(tidyverse)

#### Ouverture de Sliced_ARG_Species.tsv & recuperation des donnees ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_ARG_species.tsv') %>% 
  as.data.frame() 

uni_ARG <- sort(unique(all_species$qseqid)) # On extrait la colonne des ARGs 

#### Obtention de la liste des fichiers contenant nos matrices binaires et pseudo-binaires ####
# On se rend dans le bon emplacement puis on recherche la parterne de nom de fichier 'Sliced_Matrix_.*.tsv' qui est commune aux 2 types de matrice 
all_matrix <- list.files(path = 'W:/ninon-species/output/Output_M2/ARG/Matrice', pattern = 'Sliced_Matrix_.*.tsv', full.names = TRUE) 
n_matrix <- length(all_matrix) # On recupere le nombre de fichier contenus dans notre liste de fichier 

matrix_name <- str_replace(all_matrix, '(.*)(Matrix)_(.*).(tsv)', '\\3') # On recupere les noms de matrices a partir des noms de fichiers 

for (i in 1:n_matrix) # Permet de parcourir les matrices une par une
{
  ARG_matrix <- read_tsv(file = all_matrix[i]) # On ouvre la matrice depuis la liste de fichier
  ARG_matrix <- as.matrix(ARG_matrix) 
  rownames(ARG_matrix) <- uni_ARG 
  
  #### Barplot de la presence d un ARG donne (ici aac(6')-31_1_AM283489) ####
  # Pour definir les noms et destinations de fichiers pour l enregistrement
  deb_fr <- "W:/ninon-species/output/Output_M2/ARG/Plot/Matrice_plot/Barplot_Pres_ARG/aac(6')-31_1_AM283489/FR/Partage_inter-" 
  fin_fr <- "_fr.png" 
  deb_en <- "W:/ninon-species/output/Output_M2/ARG/Plot/Matrice_plot/Barplot_Pres_ARG/aac(6')-31_1_AM283489/EN/Partage_inter-" 
  fin_en <- "_en.png"
  # Pour definir les titres de barplots
  debut <- "Partage inter-" 
  fin <- " de " 
  start <- " inter-" 
  end <- " sharing"

  if (grepl('(.*)_(.*)', matrix_name[i]) == TRUE) # On ne fait ce plot que pour les matrices pseudo-binaires
  { # N.B. : Il suffit de changer l index dans ARG_matrix et uni_ARG et d adapter les d acces pour tester un autre ARG
    to_set <- which(ARG_matrix[32,] != 0) # On isole les colonnes pour lesquelles l ARG matche
    m <- ARG_matrix[32, c(to_set)] # On extrait lesdites colonnes
    
    png(str_glue("{deb_fr}{matrix_name[i]}{fin_fr}"), height = 1017, width = 1920, pointsize = 20)
    barplot(m, main = str_glue("{debut}{matrix_name[i]}{fin}{uni_ARG[32]}")) # Barblot de la presence de l ARG donne dans la matrice
    dev.off()
    
    png(str_glue("{deb_en}{matrix_name[i]}{fin_en}"), height = 1017, width = 1920, pointsize = 20)
    barplot(m, main = str_glue("{uni_ARG[32]}{start}{matrix_name[i]}{end}")) # Barblot de la presence de l ARG donne dans la matrice
    dev.off()
  }
  
  #### Meme chose mais avec l ensemble des ARGs en meme temps (mais ca ne marche pas donc est qu on garde ca ??) #### 
  # if (grepl('(.*)_(.*)', matrix_name[i]) == TRUE) # On ne fait ce plot que pour les matrices pseudo-binaires
  # { 
  #   to_set2 <- which(ARG_matrix != 0) # Ne peut pas etre applique directement a l ensemble de la matrice
  #   m2 <- ARG_matrix[, c(to_set2)]
  #   barplot(ARG_matrix, main = str_glue("{debut}{matrix_name[i]}"))
  #   barplot(ARG_matrix, main = str_glue("{start}{matrix_name[i]}{end}"))
  # }
  #
  # max <- 1
  # 
  # for (k in 1:ncol(ARG_matrix))
  # {
  #   if (max(ARG_matrix[, k]) > max)
  #   {
  #     max <- max(ARG_matrix[, k])
  #   }
  # }
  # 
  # ARG_matrix <- as.data.frame(ARG_matrix)
  #
  # plot <- ggplot(ARG_matrix) + geom_histogram(bins = max) # Ne marche pas pour des raisons qui m echappe
  # plot + ggtitle(str_glue("{debut}{matrix_name[i]}")) + xlab("??") + ylab("Partage")
  # plot + ggtitle(str_glue("{start}{matrix_name[i]}{end}")) + xlab("??") + ylab("Sharing")
  
  #### Dendogramme d une famille d ARG (celle de l ARG teste ci-avant tant qu a faire) ####
  ARG_family <- ARG_matrix # Preparation d une nouvelle matrice qu on va rendre specifique a une famille d ARG
  j <- 1

  for (m in 1:nrow(ARG_matrix)) # Permet de parcourir la matrice ligne par ligne
  {
    if (startsWith(uni_ARG[m], 'aac') != TRUE) # Si la ligne m ne correspond pas a un ARG de la famille voulue (ici celle des 'aac')
    { # N.B. : Il suffit de changer la paterne recherchee dans startsWith() pour tester une autre famille
      ARG_family <- ARG_family[-j,] # On supprime la ligne de notre nouvelle matrice
    }
    else # Sinon
    {
      j <- j + 1 # On passe directement a la ligne suivante
    }
  }
  
  # Pour definir les noms et destinations de fichiers pour l enregistrement
  debu <- "W:/ninon-species/output/Output_M2/ARG/Plot/Matrice_plot/Dendrogramme/aac/Dist_" 
  fine <- "_aac.png" 
  
  all_dist <- dist(ARG_family, method = 'binary') # On calcule les distances au sein de notre nouvelle matrice
  clust <- hclust(all_dist, "complete") # On clusterise ses distances
  png(str_glue("{debu}{matrix_name[i]}{fine}"), height = 1017, width = 1920, pointsize = 20)
  plot(clust) # On plot le dendogramme resultant
  dev.off()
}
