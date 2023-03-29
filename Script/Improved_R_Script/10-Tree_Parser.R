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
liste_tree_liste <- vector(mode = 'list', length = 6) # On prepare une liste des listes des sous-arbres aux 6 niveaux taxonomiques 

min_length <- vector(mode = 'list', length = 6) # On prepare une liste des distances totales de sous-arbres minimales aux 6 niveaux taxonomiques
max_length <- vector(mode = 'list', length = 6) # On prepare une liste des distances totales de sous-arbres maximales aux 6 niveaux taxonomiques

#### Fonction servant a la creation de nouvelles listes des sous-arbres par centroides et de leurs distances totales ####
liste_generator <- function(tree, tibble_tree) # Il faut l arbre sous forme phylo et sous forme tibble en entree 
{
  n_ARG <- ncol(tibble_tree)
  
  trees <- vector(mode = 'list', length = n_centro) # On prepare une liste des sous-arbres 
  length <- as.data.frame(matrix(data = 0, nrow = n_centro, ncol = 1)) # On prepare une colonne des distances des sous-arbres  
  uni_centro <- cbind(uni_centro, length) # On ajoute cette colonne a celle des centroides
  colnames(uni_centro) <- c('centroid', 'length')
  
  l <- 1
  
  for (k in 5:n_ARG) # Permet de parcourir les k colonnes associees aux centroides dans tibbled_tree (celles issues de la matrice)
  { # N.B. : On est donc oblige de demarrer a partir de la 5eme colonnes (les 4 1ere etant celles propres a l arbre)
    wanted_ARG <- colnames(tibble_tree[, k]) # On recuppere le nom de l ARG associe a la colonne k
    wanted_tip <- tibble_tree$label[tibble_tree[wanted_ARG] == 1] # On recupere les labels de tips se partagent l ARG (== les lignes pour lesquelles il y a "1" dans la colonne de l ARG)
    wanted_tip <- na.omit(wanted_tip) # On doit exclures les 'NA' qui sont apparement consideres par defauts comme correspondant au '1' recherche ci-dessus (ils correspondent aux lignes des labels de nodes dont on en veut surtout pas !)
    
    tree_ARG <- keep.tip(tree, tip = wanted_tip) # On prune l arbre complet pour ne garder que les tips selectionnes ci-avant
    length <- sum(tree_ARG$edge.length) # On somme les distances des branches du sous-arbre pour recuperer sa distance totale
    uni_centro[k - 4, 'length'] <- length # On la stock dans la nouvelle colonne de uni_centro 
    # N.B. : Les centroids sont ordonnes de la meme facon dans tibble_tree et uni_centro donc il suffit de parcourir uni-centro en parallele (en partant bien de 1 et non plus de 5 cette fois) pour etre toujour a la bonne ligne
    trees[[l]] <- tree_ARG # On stock le sous-arbre dans la liste des sous-arbre
    l <- l + 1
  }
  # Comme return ne peut s appliquer qu a une seule variable on est oblige de stocker temporairement les 2 listes ensemble
  liste <- list(trees, uni_centro) 
  return(liste)
}

#### Fonction servant a suppimer les sous-arbres vides dans une liste de sous_arbres ####
liste_parser <- function(trees, uni_centro) # Il faut la liste des sous-arbre et uni_centro (le block : centroids + distances) en entree
{
  n_centro <- nrow(uni_centro)
  
  tree_list <- vector(mode = 'list', length = n_centro) # On prepare une nouvelle liste des sous-arbres 
  
  l <- 1
  
  for (k in 1:j) # Permet de parcourir les k sous-arbres de la liste
  {
    if (is.null(trees[[k]]) == FALSE) # Si le sous-arbre k n est pas vide
    {
      tree_list[[l]] <- trees[[k]] # On le copie dans la nouvelle liste
      l <- l + 1
    }
  }
  # On renomme les sous_arbres en fonction des centroids auxquels ils sont associes (sinon il faudrait se referer constamment a uni_centro pour savoir a quel centroid est associe un sous-arbre)
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
  
  tree <- read.tree(file_name_1) # Arbre sans le traitement supplementaire des labels de nodes
  other_tree <- read.tree(file_name_2) # Arbre avec le traitement supplementaire des labels de nodes
  
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
  
  tibble_tree <- left_join(tibble_tree, centro_matrix, by = c('label' = level_name[i])) # On join la matrice au 1er arbre sur les colonnes du niveau i et des labels
  other_tibble_tree <- left_join(other_tibble_tree, centro_matrix, by = c('label' = level_name[i])) # On join la matrice au 2nd arbre sur les colonnes du niveau i et des labels
  
  #### Creation des listes des sous-arbres et de leurs distances totales par centroides ####
  liste <- liste_generator(tree, tibble_tree) # On genere la listes de sous_arbres et la nouvelle colonne d uni_centro de leurs distances totales pour le 1er arbre
  other_liste <- liste_generator(other_tree, other_tibble_tree) # Idem pour le 2nd arbre
  
  # On recupere separement la liste des sous arbre et uni_centro pour les 2 arbres
  trees <- liste[[1]] 
  other_trees <- other_liste[[1]]  
  
  uni_centro <- liste[[2]]
  other_uni_centro <- other_liste[[2]]
  
  #### Exemple de plot d un sous_arbre avec "blaNDM-18_1_KY503030" (pour le 1er arbre uniquement parce que c est pareil si on le fait avec l autre) ####
  plot.phylo(trees[[358]], show.node.label = TRUE, main = uni_centro[358, 1], sub = uni_centro[358, 2])
  # N.B. : Pour travailler avec un autre centroide il faut modifier l index dans trees et uni_centro dans la ligne ci-avant
  # Index des 4 centroides que j ai choisis comme representants : 178 - 297 - 358 - 1237 (meme ordre que dans le ppt)
  
  #### Suppresion des sous_arbres vides et de leurs distances totales (genant pour la suite) ####
  err <- which(uni_centro[, 'length'] == 0.000) # On isole les lignes associees a des distances totales null (celles des sous-arbres vides) pour le 1er arbre
  other_err <- which(other_uni_centro[, 'length'] == 0.000) # Idem pour le 2nd arbre

  uni_centro <- uni_centro[-c(err),] # On supprime ces lignes de uni_centro pour le 1er arbre
  other_uni_centro <- other_uni_centro[-c(other_err),] # Idem pour le 2nd arbre

  tree_list <- liste_parser(trees, uni_centro) # On genere la nouvelle liste des sous-arbres sans ceux vides pour le 1er arbre
  other_tree_list <- liste_parser(other_trees, other_uni_centro) # Idem pour le 2nd arbre

  #### Histogramme des distances totales des sous-arbres (la encore c est identique pour les 2 arbres donc on le fait que pour le 1er) ####
  level_length <- uni_centro['length']

  level_plot <- ggplot(level_length, aes(length)) + geom_histogram(bins = n_centro)

  title = "Nombres d'occurrences des valeurs de distances inter-" # Pour generer le titre en francais
  title_start = "Inter-" # Pour generer le debut du titre en anglais
  title_end = " sharing value occurences" # Pour generer la fin du titre en anglais
  # On fait un premier plot avec le titre et les legendes en francais puis un second avec le titre et les legendes en anglais
  plot(level_plot + ggtitle(label = str_glue("{title}{level_name[i]}")) + xlab("Valeurs des distances") + ylab("Nombres d'occurrences"))
  plot(level_plot + ggtitle(label = str_glue("{title_start}{level_name[i]}{title_end}")) + xlab("Distances values") + ylab("Number of occurences"))

  #### Plot des sous-arbres des especes par centroides sur l arbre complet (Pour le 2nd arbre cette fois parce que ca ne peut pas fonctionner sans le traitement supplementaire des labels de nodes !!) ####
  liste <- vector(mode = 'list', length = nrow(other_uni_centro)) # On prepare une nouvelle liste

  for (l in 1:nrow(other_uni_centro)) # Permet de parcourir les l sous-arbre de la liste
  {
    wanted_tree <- as_tibble(other_tree_list[[l]]) # On recupere le sous-arbre l sous la forme d un tibble
    root <- which(is.na(wanted_tree['branch.length']) == TRUE) # On isole la ligne associee a sa racine dont la distance est la seule non renseignee (== 'NA')
    label <- which(other_tibble_tree$label %in% wanted_tree[root, 'label']) # On isole les lignes de meme label que sa racine dans l arbre complet
    liste[l] <- other_tibble_tree[label, 'node'] # On recuppere les numeros de node associes a ces ligne dans la nouvelle liste
  }
  # N.B. : La colonne 'type' sert a donner des types distinct aux sous-arbres lors du plot via une numerotation pour pouvoir les coloriser tous differement sur l arbre complet
  liste <- t(as.data.frame(unique(liste))) # On transforme la liste ainsi remplie en dataframe dedoublonnee (ca necessite une transposition)
  type <- as.data.frame(matrix(data = 1:length(liste), nrow = length(liste), ncol = 1)) # On prepare une nouvelle colonne remplie avec des nombres allant de 1 au nombre de sous-arbres
  liste <- cbind(liste, type) # On ajoute cette colonne a notre dataframe dedoublonnee
  names(liste) <- c('node', 'type')
  # geom_highlight permet de coloriser les sous-arbres en fonction du type associe. Il fallait donc definir autant de types differents qu il y a de sous-arbres pour attribuer une teinte unique a chacun
  level_tree <- ggtree(other_tree) + geom_hilight(data = liste, mapping = aes(node = node, fill = type))

  deb <- "Sous-arbres " # Pour generer le debut du titre en francais
  fin <- "/centroides" # Pour generer la fin du titre en francais
  fin_en <- "/centroids sub-trees" # Pour generer le titre en anglais
  # On fait un premier plot avec le titre en francais puis un second avec le titre en anglais
  plot(level_tree + ggtitle(str_glue("{deb}{level_name[i]}{fin}")))
  plot(level_tree + ggtitle(str_glue("{level_name[i]}{fin_en}")))

  liste_uni_centro[[i]] <- uni_centro # On stock uni_centro dans la liste prevue pour ca
  liste_tree_liste[[i]] <- tree_list # On stock la liste des sous-arbre dans la liste prevue pour ca

  min_length[[i]] <- min(uni_centro[, 2]) # On recupere la valeur de distance totale minimale dans la liste prevue pour ca
  max_length[[i]] <- max(uni_centro[, 2]) # On recupere la valeur de distance totale maximale dans la liste prevue pour ca
}
