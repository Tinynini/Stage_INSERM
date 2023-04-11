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
liste_uni_ARG <- vector(mode = 'list', length = 6) # On prepare une liste des listes des ARG et des distances totales de leurs sous-arbres aux 6 niveaux taxonomiques 
liste_tree_liste <- vector(mode = 'list', length = 6) # On prepare une liste des listes des sous-arbres aux 6 niveaux taxonomiques 

min_length <- vector(mode = 'list', length = 6) # On prepare une liste des distances totales de sous-arbres minimales aux 6 niveaux taxonomiques
max_length <- vector(mode = 'list', length = 6) # On prepare une liste des distances totales de sous-arbres maximales aux 6 niveaux taxonomiques

#### Fonction servant a la creation de nouvelles listes des sous-arbres par ARGs et de leurs distances totales ####
liste_generator <- function(tree, tibble_tree) # Il faut l arbre sous forme phylo et sous forme tibble en entree 
{
  n_arg <- ncol(tibble_tree)
  
  trees <- vector(mode = 'list', length = n_ARG) # On prepare une liste des sous-arbres 
  length <- as.data.frame(matrix(data = 0, nrow = n_ARG, ncol = 1)) # On prepare une colonne des distances des sous-arbres  
  uni_ARG <- cbind(uni_ARG, length) # On ajoute cette colonne a celle des ARGs
  colnames(uni_ARG) <- c('ARG', 'length')
  
  l <- 1
  
  for (k in 5:n_arg) # Permet de parcourir les k colonnes associees aux ARGs dans tibbled_tree (celles issues de la matrice)
  { # N.B. : On est donc oblige de demarrer a partir de la 5eme colonnes (les 4 1ere etant celles propres a l arbre)
    wanted_ARG <- colnames(tibble_tree[, k]) # On recuppere le nom de l ARG associe a la colonne k
    wanted_tip <- tibble_tree$label[tibble_tree[wanted_ARG] == 1] # On recupere les labels de tips se partagent l ARG (== les lignes pour lesquelles il y a "1" dans la colonne de l ARG)
    wanted_tip <- na.omit(wanted_tip) # On doit exclures les 'NA' qui sont apparement consideres par defauts comme correspondant au '1' recherche ci-dessus (ils correspondent aux lignes des labels de nodes dont on en veut surtout pas !)
    
    tree_ARG <- keep.tip(tree, tip = wanted_tip) # On prune l arbre complet pour ne garder que les tips selectionnes ci-avant
    length <- sum(tree_ARG$edge.length) # On somme les distances des branches du sous-arbre pour recuperer sa distance totale
    uni_ARG[k - 4, 'length'] <- length # On la stock dans la nouvelle colonne de uni_ARG 
    # N.B. : Les ARGs sont ordonnes de la meme facon dans tibble_tree et uni_ARG donc il suffit de parcourir uni-ARG en parallele (en partant bien de 1 et non plus de 5 cette fois) pour etre toujour a la bonne ligne
    trees[[l]] <- tree_ARG # On stock le sous-arbre dans la liste des sous-arbre
    l <- l + 1
  }
  # Comme return ne peut s appliquer qu a une seule variable on est oblige de stocker temporairement les 2 listes ensemble
  liste <- list(trees, uni_ARG) 
  return(liste)
}

#### Fonction servant a suppimer les sous-arbres vides dans une liste de sous_arbres ####
liste_parser <- function(trees, uni_ARG) # Il faut la liste des sous-arbre et uni_ARG (le block : ARG + distance) en entree
{
  n_ARG <- nrow(uni_ARG)
  
  tree_list <- vector(mode = 'list', length = n_ARG) # On prepare une nouvelle liste des sous-arbres 
  
  l <- 1
  
  for (k in 1:j) # Permet de parcourir les k sous-arbres de la liste
  {
    if (is.null(trees[[k]]) == FALSE) # Si le sous-arbre k n est pas vide
    {
      tree_list[[l]] <- trees[[k]] # On le copie dans la nouvelle liste
      l <- l + 1
    }
  }
  # On renomme les sous_arbres en fonction des ARGs auxquels ils sont associes (sinon il faudrait se referer constamment a uni_ARG pour savoir a quel ARG est associe un sous-arbre)
  names(tree_list) <- uni_ARG[, 'ARG'] 
  return(tree_list)
}

#### Main ####
for (i in 1:6) # Permet de parcourir les 6 niveaux taxonomiques etudies (d espece a phylum)
{
  #### Ouverture des arbres du niveau i depuis leurs fichiers nominatifs & preparation des donnees ####
  path_start <- "W:/ninon-species/output/Output_M2/ARG/Arbre/"
  path_end <- ".tree"
  other_path_end = "_version_alt.tree"
  # Les noms des fichiers sont definis par des variables
  file_name_1 <- str_glue("{path_start}{level_name[i]}{path_end}") 
  file_name_2 <- str_glue("{path_start}{level_name[i]}{other_path_end}")
  
  tree <- read.tree(file_name_1) # Arbre sans le traitement supplementaire des labels de nodes
  other_tree <- read.tree(file_name_2) # Arbre avec le traitement supplementaire des labels de nodes
  
  tibble_tree <- as_tibble(tree) # On passe au format tibble plus pratique a manipuler
  other_tibble_tree <- as_tibble(other_tree) # On passe au format tibble plus pratique a manipuler
  
  uni_ARG <- sort(unique(all_species$qseqid)) # On extrait la colonne des ARGs
  n_ARG <- length(uni_ARG)

  uni_level <- as.data.frame(sort(unique(level[, i]))) # On extrait la colonne du niveau i
  colnames(uni_level) <- level_name[i]
  n_level <- nrow(uni_level)

  #### Creaction d une matrice binaire (0/1) d absence/presence des genes de resistances au niveau i ####
  ARG_matrix <- matrix(data = 0, nrow = n_ARG, ncol = n_level)
  rownames(ARG_matrix) <- uni_ARG

  for (j in 1:n_ARG) # Permet de parcourir les j ARGs distincts
  {
    curr_ARG <- uni_ARG[j] # Pour l ARG j
    curr_level <- all_species[all_species$qseqid == curr_ARG, level_name[i]] # Au niveau i

    to_set <- which(uni_level[, level_name[i]] %in% curr_level) # On extrait les representants du niveau i qui matchent l ARG j
    ARG_matrix[j, to_set] <- 1 # On attribue la valeur 1 aux cases associees a ces matchs dans la matrice
  }

  #### Join de l arbre et de la matrice & preparation de nouvelles listes ####
  ARG_matrix <- t(ARG_matrix) # On transpose la matrice pour avoir les representants du niveau i en ligne
  ARG_matrix <- as.data.frame(ARG_matrix) # On transforme la matrice en dataframe
  ARG_matrix <- cbind(uni_level, ARG_matrix) # On combine la colonne du niveau i a la matrice en vue du join avec l arbre du niveau i

  tibble_tree <- left_join(tibble_tree, ARG_matrix, by = c('label' = level_name[i])) # On join la matrice au 1er arbre sur les colonnes du niveau i et des labels
  other_tibble_tree <- left_join(other_tibble_tree, ARG_matrix, by = c('label' = level_name[i])) # On join la matrice au 2nd arbre sur les colonnes du niveau i et des labels

  #### Creation des listes des sous-arbres et de leurs distances totales par ARGs ####
  liste <- liste_generator(tree, tibble_tree) # On genere la listes de sous_arbres et la nouvelle colonne d uni_ARG de leurs distances totales pour le 1er arbre
  other_liste <- liste_generator(other_tree, other_tibble_tree) # Idem pour le 2nd arbre

  # On recupere separement la liste des sous arbre et uni_ARG pour les 2 arbres
  trees <- liste[[1]]
  other_trees <- other_liste[[1]]

  uni_ARG <- liste[[2]]
  other_uni_ARG <- other_liste[[2]]

  #### Exemple de plot d un sous_arbre avec "blaNDM-9_1_KC999080" (pour le 1er arbre uniquement parce que c est pareil si on le fait avec l autre) ####
  plot.phylo(trees[[402]], show.node.label = TRUE, main = uni_ARG[402, 1], sub = uni_ARG[402, 2])
  # N.B. : Pour travailler avec un autre ARG il faut modifier l index dans trees et uni_ARG dans la ligne ci-avant
  # Index des 4 ARGs que j ai choisis comme representants : 174 - 320 - 402 - 1446 (meme ordre que dans le ppt)

  #### Suppresion des sous_arbres vides et de leurs distances totales (genant pour la suite) ####
  err <- which(uni_ARG[, 'length'] == 0.000) # On isole les lignes associees a des distances totales null (celles des sous-arbres vides) pour le 1er arbre
  other_err <- which(other_uni_ARG[, 'length'] == 0.000) # Idem pour le 2nd arbre

  uni_ARG <- uni_ARG[-c(err),] # On supprime ces lignes de uni_ARG pour le 1er arbre
  other_uni_ARG <- other_uni_ARG[-c(other_err),] # Idem pour le 2nd arbre

  tree_list <- liste_parser(trees, uni_ARG) # On genere la nouvelle liste des sous-arbres sans ceux vides pour le 1er arbre
  other_tree_list <- liste_parser(other_trees, other_uni_ARG) # Idem pour le 2nd arbre

  #### Histogramme des distances totales des sous-arbres (la encore c est identique pour les 2 arbres donc on le fait que pour le 1er) ####
  level_length <- uni_ARG['length']
  # Pour definir les noms et destinations de fichiers pour l enregistrement
  start <- 'Dist_'
  end_fr <- '_fr.png'
  end_en <- '_en.png'
  # Pour definir les titres de plots
  title_fr <- "Nombres d'occurrences des valeurs de distances inter-" 
  title_start_en <- "Inter-"
  title_end_en <- " sharing value occurences" 
  # On fait un premier plot avec le titre et les legendes en francais puis un second avec le titre et les legendes en anglais
  ggplot(level_length, aes(length)) + geom_histogram(bins = n_ARG) + ggtitle(label = str_glue("{title_fr}{level_name[i]}")) + xlab("Valeurs des distances") + ylab("Nombres d'occurrences")
  ggsave(str_glue("{start}{level_name[i]}{end_fr}"), plot = last_plot(), device = "png", path = "W:/ninon-species/output/Output_M2/ARG/Plot/Distance_plot/FR", width = 16, height = 8.47504)
  ggplot(level_length, aes(length)) + geom_histogram(bins = n_ARG) + ggtitle(label = str_glue("{title_start_en}{level_name[i]}{title_end_en}")) + xlab("Distances values") + ylab("Number of occurences")
  ggsave(str_glue("{start}{level_name[i]}{end_en}"), plot = last_plot(), device = "png", path = "W:/ninon-species/output/Output_M2/ARG/Plot/Distance_plot/EN", width = 16, height = 8.47504)
  
  #### Plot des sous-arbres des especes par ARGs sur l arbre complet (Pour le 2nd arbre cette fois parce que ca ne peut pas fonctionner sans le traitement supplementaire des labels de nodes !!) ####
  liste <- vector(mode = 'list', length = length(other_tree_list)) # On prepare une nouvelle liste

  for (m in 1:length(other_tree_list)) # Permet de parcourir les m sous-arbre de la liste
  {
    wanted_tree <- as_tibble(other_tree_list[[m]]) # On recupere le sous-arbre m sous la forme d un tibble
    root <- which(is.na(wanted_tree['branch.length']) == TRUE) # On isole la ligne associee a sa racine dont la distance est la seule non renseignee (== 'NA')
    label <- which(other_tibble_tree$label %in% wanted_tree[root, 'label']) # On isole les lignes de meme label que sa racine dans l arbre complet
    liste[m] <- other_tibble_tree[label, 'node'] # On recuppere les numeros de node associes a ces ligne dans la nouvelle liste
  }
  # N.B. : La colonne 'type' sert a donner des types distinct aux sous-arbres lors du plot via une numerotation pour pouvoir les coloriser tous differement sur l arbre complet
  liste <- t(as.data.frame(unique(liste))) # On transforme la liste ainsi remplie en dataframe dedoublonnee (ca necessite une transposition)
  type <- as.data.frame(matrix(data = 1:length(liste), nrow = length(liste), ncol = 1)) # On prepare une nouvelle colonne remplie avec des nombres allant de 1 au nombre de sous-arbres
  liste <- cbind(liste, type) # On ajoute cette colonne a notre dataframe dedoublonnee
  names(liste) <- c('node', 'type')
  # geom_highlight permet de coloriser les sous-arbres en fonction du type associe. Il fallait donc definir autant de types differents qu il y a de sous-arbres pour attribuer une teinte unique a chacun
  level_tree <- ggtree(other_tree) + geom_hilight(data = liste, mapping = aes(node = node, fill = type))

  deb <- "Sous-arbres " # Pour generer le debut du titre en francais
  fin_fr <- "/ARG" # Pour generer la fin du titre en francais
  fin_en <- "/ARG sub-trees" # Pour generer le titre en anglais
  # On fait un premier plot avec le titre en francais puis un second avec le titre en anglais
  plot(level_tree + ggtitle(str_glue("{deb}{level_name[i]}{fin_fr}")))
  plot(level_tree + ggtitle(str_glue("{level_name[i]}{fin_en}")))

  liste_uni_ARG[[i]] <- uni_ARG # On stock uni_ARG dans la liste prevue pour ca
  liste_tree_liste[[i]] <- tree_list # On stock la liste des sous-arbre dans la liste prevue pour ca

  min_length[[i]] <- min(uni_ARG[, 2]) # On recupere la valeur de distance totale minimale dans la liste prevue pour ca
  max_length[[i]] <- max(uni_ARG[, 2]) # On recupere la valeur de distance totale maximale dans la liste prevue pour ca
}
