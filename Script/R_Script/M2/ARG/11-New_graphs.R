library(tidyverse)
library(tidytree)
library(ape)
library(cowplot)

############################################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                                                     #
# Utilite == generer les histogrammes de toutes les distances cophenetiques et les courbes #
# de tendances des distances cophenetiques max et a E.coli à chaque niveaux taxonomiques   #
# Input == Sliced_Taxo_Result.tsv, les 12 fichiers 'level_name[i]'*.tree, et le fichier    #
# listes.RData contenant les listes des sous_arbres et des genes a tout les niveaux        #
# Output == les 6 histogrammes des toutes les distances cophenentics (en FR et EN), et les #
# 12 courbes de tendances des distances cophenitiques max et a E.coli (en FR et EN)        #
############################################################################################

#### Ouverture de Sliced_Taxo_Result.tsv & recuperation des donnees ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_taxo_Result.tsv', col_types = "ccddcccccccdddddd") %>%
  as.data.frame

# On est oblige de modifier la nomenclature des noms d especes pour coller avec celle de l arbre et de la matrice cophenetique des especes
all_species[, 'species'] <- str_replace(all_species[, 'species'], '(.*) (.*)', '\\1\\_\\2')
level_name <- unlist(colnames(all_species[, c(6:11)])) # On extrait aussi les labels des 6 niveaux taxonomiques
# On recupere les listes de sous-arbres et de genes aux 6 niveaux taxonomiques
load("W:/ninon-species/output/Output_M2/ARG/listes.RData")

# Pour definir les titres de plots
title_start <- "Inter-"

title_all_fr <- "Nombres d'occurrences des valeurs de distances cophénétiques inter-"
title_max_fr <- "Distances cophenetiques en fonction des partages inter-"
title_coli_fr <- "Distances cophenetiques en fonction des partages inter-"

title_all_en <- " cophenetic distances values occurences"
title_max_en <- " cophenetique distances in function of sharings"
title_coli_en <- " cophenetique distances in function of sharings"

# Pour definir les noms et destinations de fichiers pour l enregistrement
start <- 'Dist_'
end_fr <- '_fr.png'
end_en <- '_en.png'

path_all_fr = "W:/ninon-species/output/Output_M2/ARG/Plot/Distance_plot/All_distances/FR"
path_max_fr = "W:/ninon-species/output/Output_M2/ARG/Plot/Distance_plot/Max_distances/FR"
path_coli_fr = "W:/ninon-species/output/Output_M2/ARG/Plot/Distance_plot/Coli_distances/FR"

path_all_en = "W:/ninon-species/output/Output_M2/ARG/Plot/Distance_plot/All_distances/EN"
path_max_en = "W:/ninon-species/output/Output_M2/ARG/Plot/Distance_plot/Max_distances/EN"
path_coli_en = "W:/ninon-species/output/Output_M2/ARG/Plot/Distance_plot/Coli_distances/EN"

#### Fonction de plot des histogrammes des distances cophenetiques des sous-arbres ####
hist_plot <- function(dist_set, suffix, path_fr, path_en, title_fr, title_en) 
{
  # On fait un premier plot avec le titre et les legendes en francais puis un second avec le titre et les legendes en anglais
  plt_1 <- ggplot(dist_set, aes(length)) + geom_histogram(bins = 50)
  plt_2 <- ggplot(dist_set, aes(length)) + stat_density(trim = TRUE)
  plot_grid(plt_1, plt_2, align="hv") + ggtitle(label = str_glue("{title_fr}{level_name[i]}"))
  ggsave(str_glue("{start}{suffix}{level_name[i]}{end_fr}"), plot = last_plot(), device = "png", path = path_fr, width = 16, height = 8.47504)
  plot_grid(plt_1, plt_2, align="hv") + ggtitle(label = str_glue("{title_start}{level_name[i]}{title_en}"))
  ggsave(str_glue("{start}{suffix}{level_name[i]}{end_en}"), plot = last_plot(), device = "png", path = path_en, width = 16, height = 8.47504)
}

#### Fonction de plot des courbes de tendance des distances cophenetics en fonction des partages ####
smooth_plot <- function(dist_set, suffix, path_fr, path_en, title_fr, title_en) 
{
  # On fait un premier plot avec le titre et les legendes en francais puis un second avec le titre et les legendes en anglais
  plt <- ggplot(dist_set, aes(length, share)) + geom_point() + ggtitle(label = str_glue("{title_fr}{level_name[i]}")) + xlab("Valeurs des distances") + ylab("valeurs des partages")
  plt + stat_smooth(method = "loess", n = 1000)
  ggsave(str_glue("{start}{suffix}{level_name[i]}{end_fr}"), plot = last_plot(), device = "png", path = path_fr, width = 16, height = 8.47504)
  plt <- ggplot(dist_set, aes(length, share)) + geom_point() + ggtitle(label = str_glue("{title_start}{level_name[i]}{title_en}")) + xlab("Distance values") + ylab("sharing values")
  plt + stat_smooth(method = "loess", n = 1000) 
  ggsave(str_glue("{start}{suffix}{level_name[i]}{end_en}"), plot = last_plot(), device = "png", path = path_en, width = 16, height = 8.47504)
}
 
### Main ####
taxo_coli <- c('Escherichia_coli', 'Escherichia', 'Enterobacteriaceae', 'Enterobacterales', 'Gammaproteobacteria', 'Proteobacteria')

for (i in 1:6) # Permet de parcourir les 6 niveaux taxonomiques etudies (d espece a phylum)
{
  # Ouverture de l arbre du niveau i depuis son fichier nominatif & preparation des donnees
  path_start <- "W:/ninon-species/output/Output_M2/ARG/Arbre/"
  path_end <- ".tree"
  file_name <- str_glue("{path_start}{level_name[i]}{path_end}") # Le nom du fichier est defini par une variable
  
  tree <- read.tree(file_name) # Arbre sans le traitement supplementaire des labels de nodes
  tibble_tree <- as_tibble(tree) # On passe au format tibble plus pratique a manipuler
  
  uni_gene <- liste_uni_gene[[i]]
  tree_liste <- liste_tree_liste[[i]]

  level_share <- all_species[, c(2, i + 5, i + 11)]
  level_share <- unique(level_share)

  uni_level_share <- left_join(uni_gene, level_share, by = c('gene' = 'Centroid'))
  uni_level_share <- unique(uni_level_share[, -2])
  colnames(uni_level_share) <- c('gene', 'level', 'share')
  uni_level_share <- unique(uni_level_share[-c(which(is.na(uni_level_share[, 'level']) == TRUE)),])

  # Obtention des distances cophenetics dans dist_all et des distances cophenetics max dans dist_max
  if (Ntip(tree_liste[[1]]) > 1)
  {
    all_dist <- unlist(as.data.frame(cophenetic.phylo(tree_liste[[1]])))
    max_dist <- cbind(uni_gene[1, 1], as.data.frame(max(cophenetic.phylo(tree_liste[[1]]))))
  }

  else
  {
    all_dist <- unlist(uni_gene[1, 2])
    max_dist <- uni_gene[1,]
  }

  colnames(max_dist) <- c('gene', 'length')

  for (j in 2:length(tree_liste))
  {
    if (Ntip(tree_liste[[j]]) > 1)
    {
      new_all_dist <- unlist(as.data.frame(cophenetic.phylo(tree_liste[[j]])))
      new_max_dist <- cbind(uni_gene[j, 1], as.data.frame(max(cophenetic.phylo(tree_liste[[j]]))))
    }

    else
    {
      new_all_dist <- unlist(uni_gene[j, 2])
      new_max_dist <- uni_gene[j,]
    }

    all_dist <- c(all_dist, new_all_dist)
    colnames(new_max_dist) <- c('gene', 'length')
    max_dist <- rbind(max_dist, new_max_dist)
  }

  all_dist <- all_dist[c(which(all_dist != 0))]
  all_dist <- as.data.frame(all_dist)
  colnames(all_dist) <- 'length'
  
  max_dist <- left_join(max_dist, uni_level_share, by = c('gene' = 'gene'))
  max_dist <- max_dist[, -3]

  max_dist %>%
    group_by(gene) %>%
    arrange(length) %>%
    slice_tail() -> max_dist

  # Obtention des distances cophenetics a E.coli dans dist_coli
  m_coph <- cophenetic.phylo(tree)
  m_coph <- cbind(tibble_tree[c(1:nrow(m_coph)), 'label'], m_coph)

  m_coli <- as.data.frame(m_coph[, c('label', taxo_coli[i])])
  coli_dist <- left_join(uni_level_share, m_coli, by = c('level' = 'label'))
  colnames(coli_dist) <- c('gene', 'level', 'share', 'length')
  coli_dist <- coli_dist[, -2]

  coli_dist %>%
    group_by(gene) %>%
    arrange(length) %>%
    slice_tail() -> coli_dist
  
  # Plot des histogrammes et des courbes de tendances
  hist_plot(all_dist, 'all_hist_', path_all_fr, path_all_en, title_all_fr, title_all_en)
  smooth_plot(max_dist, 'max_smooth_', path_max_fr, path_max_en, title_max_fr, title_max_en)
  smooth_plot(coli_dist, 'coli_smooth_', path_coli_fr, path_coli_en, title_coli_fr, title_coli_en)
}