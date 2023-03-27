library(tidyverse)
library(tidytree)
library(ape)
library(ggtree) 

#### Ouverture de Sliced_Taxo_Result.tsv & recuperation des donnees ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_Taxo_Result.tsv') %>% 
  as.data.frame

# On est oblige de modifier la nomenclature des noms d especes parce qu une modification automatique se fait au niveau des labels de tips de l arbre des especes 
all_species[, 'species'] <- str_replace(all_species[, 'species'], '(.*) (.*)', '\\1\\_\\2')

level <- as.data.frame(all_species[, c(6:11)]) # On extrait le contenu des colonnes associes aux 6 niveaux taxonomiques etudies
level_name <- unlist(colnames(all_species[, c(6:11)])) # On extrait aussi leurs labels pour pouvoir travailler a un niveau donne plus facilement

#### Preparation des futures listes dans lesquels seront reunies celles obtenues aux 6 niveaux taxonomiques ####
liste_uni_centro <- vector(mode = 'list', length = 6) # On prepare une liste des listes des centroids et des distances totales de leurs sous-arbres aux 6 niveaux taxonomiques 
liste_tree_liste <- vector(mode = 'list', length = 6) # On prepare une liste des listes de sous-arbres aux 6 niveaux taxonomiques 

min_length <- vector(mode = 'list', length = 6) # On prepare une liste des distances totales de sous-arbres minimales aux 6 niveaux taxonomiques
max_length <- vector(mode = 'list', length = 6) # On prepare une liste des distances totales de sous-arbres maximales aux 6 niveaux taxonomiques

#### fonction servant la creation de nouvelles listes des sous-arbres par centroides et de leurs distances totales ####
liste_generator <- function(tree, tibble_tree) 
{
  n_ARG <- ncol(tibble_tree)
  
  trees <- vector(mode = 'list', length = n_centro)
  length <- as.data.frame(matrix(data = 0, nrow = n_centro, ncol = 1))
  uni_centro <- cbind(uni_centro, length)
  colnames(uni_centro) <- c('centroid', 'length')
  
  l <- 1
  
  for (k in 5:n_ARG)
  {
    wanted_ARG <- colnames(tibble_tree[, k])
    wanted_tip <- tibble_tree$label[tibble_tree[wanted_ARG] == 1]
    wanted_tip <- na.omit(wanted_tip)
    
    tree_ARG <- keep.tip(tree, tip = wanted_tip)
    length <- sum(tree_ARG$edge.length)
    uni_centro[k - 4, 'length'] <- length
    
    trees[[l]] <- tree_ARG
    l <- l + 1
  }
  
  liste <- list(trees, uni_centro)
  return(liste)
}

liste_parser <- function(trees, uni_centro) 
{
  n_centro <- nrow(uni_centro)
  
  tree_list <- vector(mode = 'list', length = n_centro)
  
  l <- 1
  
  for (k in 1:j)
  {
    if (is.null(trees[[k]]) == FALSE)
    {
      tree_list[[l]] <- trees[[k]]
      l <- l + 1
    }
  }
  
  names(tree_list) <- uni_centro[, 'centroid']
  return(tree_list)
}

#### Main ####
for (i in 1:6) # Permet de parcourir les 6 niveaux taxonomiques etudies (d espece a phylum)
{
  #### Ouverture des arbres du niveau i depuis leurs fichiers nominatifs & preparation des donnees ####
  path_start = "W:/ninon-species/output/Output_M2/ARG/Arbre/"
  path_end = ".tree"
  other_path_end = "_version_alt.tree"
  # Les noms des fichiers sont definis par des variables
  file_name_1 = str_glue("{path_start}{level_name[i]}{path_end}") 
  file_name_2 = str_glue("{path_start}{level_name[i]}{other_path_end}")
  
  tree <- read.tree(file_name_1)
  other_tree <- read.tree(file_name_2)
  
  tibble_tree <- as_tibble(tree) # On passe au format tibble plus pratique a manipuler
  other_tibble_tree <- as_tibble(other_tree) # On passe au format tibble plus pratique a manipuler
  
  uni_centro <- sort(unique(all_species$Centroid)) # On extrait la colonne des centroids
  n_centro <- length(uni_centro)

  uni_level <- as.data.frame(sort(unique(level[, i]))) # On extrait la colonne du niveau i
  colnames(uni_level) <- level_name[i]
  n_level <- nrow(uni_level)

  #### Creaction d une matrice binaire (0/1) d absence/presence des genes de resistances au niveau i ####
  centro_matrix <- matrix(data = 0, nrow = n_centro, ncol = n_level)
  rownames(centro_matrix) <- uni_centro

  for (j in 1:n_centro) # Permet de parcourir les j centroids distincts
  {
    curr_centro <- uni_centro[j] # Pour le centroid j
    curr_level <- all_species[all_species$Centroid == curr_centro, level_name[i]] # Au niveau i

    to_set <- which(uni_level[, level_name[i]] %in% curr_level) # On extrait les representants du niveau i qui matchent le centroid j
    centro_matrix[j, to_set] <- 1 # On attribue la valeur 1 aux cases associees a ces matchs dans la matrice
  }

  #### Join de l arbre et de la matrice & preparation de nouvelles listes ####
  centro_matrix <- t(centro_matrix) # On transpose la matrice pour avoir les representants du niveau i en ligne
  centro_matrix <- as.data.frame(centro_matrix) # On transforme la matrice en dataframe
  centro_matrix <- cbind(uni_level, centro_matrix) # On combine la colonne du niveau i a la matrice en vue du join avec l arbre du niveau i
  
  tibble_tree <- left_join(tibble_tree, centro_matrix, by = c('label' = level_name[i]))
  other_tibble_tree <- left_join(other_tibble_tree, centro_matrix, by = c('label' = level_name[i]))
  
  #### Creation des listes des sous-arbres et de leurs longueurs totales par centroides ####
  liste <- liste_generator(tree, tibble_tree)
  other_liste <- liste_generator(other_tree, other_tibble_tree)
  
  trees <- liste[[1]] 
  other_trees <- other_liste[[1]]  
  
  uni_centro <- liste[[2]]
  other_uni_centro <- other_liste[[2]]
  
  #### Exemple de plot d un sous_arbre avec "blaNDM-18_1_KY503030" ####
  plot.phylo(trees[[358]], show.node.label = TRUE, main = uni_centro[358, 1], sub = uni_centro[358, 2])
  
  err <- which(uni_centro[, 'length'] == 0.000)
  other_err <- which(other_uni_centro[, 'length'] == 0.000)
  
  uni_centro <- uni_centro[-c(err),]
  other_uni_centro <- other_uni_centro[-c(other_err),]
  
  tree_list <- liste_parser(trees, uni_centro)
  other_tree_list <- liste_parser(other_trees, other_uni_centro)
  
  level_length <- uni_centro['length']
  
  level_plot <- ggplot(level_length, aes(length)) + geom_histogram(bins = n_centro)
  title = "Nombres d'occurrences des valeurs de distances inter-"
  tit <- str_glue("{title}{level_name[i]}")
  plot(level_plot + ggtitle(label = tit) + xlab("valeurs des distances") + ylab("Nombres d'occurrences"))
  
  #### Plot des sous-arbres des especes par centroides sur l arbre complet ####
  liste <- vector(mode = 'list', length = nrow(other_uni_centro))

  for (l in 1:nrow(other_uni_centro))
  {
    wanted_tree <- as_tibble(other_tree_list[[l]])
    root <- which(is.na(wanted_tree['branch.length']) == TRUE)
    label <- which(other_tibble_tree$label %in% wanted_tree[root, 'label'])
    liste[l] <- other_tibble_tree[label, 'node']
  }

  liste <- t(as.data.frame(unique(liste)))
  type <- as.data.frame(matrix(data = 1:length(liste), nrow = length(liste), ncol = 1))
  liste <- cbind(liste, type)
  names(liste) <- c('node', 'type')

  level_tree <- ggtree(other_tree) + geom_hilight(data = liste, mapping = aes(node = node, fill = type))
  deb <- "sous-arbres "
  fin <- "/centroides"
  plot(level_tree + ggtitle(str_glue("{deb}{level_name[i]}{fin}")))

  liste_uni_centro[[i]] <- uni_centro
  liste_tree_liste[[i]] <- tree_list

  min_length[[i]] <- min(uni_centro[, 2])
  max_length[[i]] <- max(uni_centro[, 2])
}
