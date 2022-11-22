library(tidyverse)
library(tidytree)
library(ape)
library(ggtree) 

#all_species <- read_tsv('W:/ninon-species/output/Total_Taxo_Result.tsv') %>%
all_species <- read_tsv('W:/ninon-species/output/Sliced_Taxo_Result.tsv') %>% 
  as.data.frame

level <- as.data.frame(all_species[, c(6:11)])
level_name <- unlist(colnames(all_species[, c(6:11)]))

liste_uni_centro <- vector(mode = 'list', length = 6) # Rendre plus exploitable ??
liste_tree_liste <- vector(mode = 'list', length = 6)

for (i in 1:6)
{
  path_start = "W:/ninon-species/output/"
  path_end = ".tree"
  file_name = str_glue("{path_start}{level_name[i]}{path_end}")

  tree <- read.tree(file_name)
  tibble_tree <- as_tibble(tree)
  
  uni_centro <- sort(unique(all_species$Centroid))
  n_centro <- length(uni_centro)
  
  uni_level <- as.data.frame(sort(unique(level[, i])))
  colnames(uni_level) <- level_name[i]
  n_level <- nrow(uni_level)

  centro_matrix <- matrix(data = 0, nrow = n_centro, ncol = n_level)
  rownames(centro_matrix) <- uni_centro

  for (j in 1:n_centro)
  {
    curr_centro <- uni_centro[j]
    curr_level <- all_species[all_species$Centroid == curr_centro, level_name[i]]
    to_set <- which(uni_level[, level_name[i]] %in% curr_level)
    centro_matrix[j, to_set] <- 1
  }

  centro_matrix <- t(centro_matrix)
  centro_matrix <- as.data.frame(centro_matrix)
  uni_level[, level_name[i]] <- str_replace(uni_level[, level_name[i]], '(.*) (.*)', '\\1\\_\\2')
  centro_matrix <- cbind(uni_level, centro_matrix)

  tibble_tree <- left_join(tibble_tree, centro_matrix, by = c('label' = level_name[i]))

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
  
  plot.phylo(trees[[297]], show.node.label = TRUE, main = uni_centro[297, 1], sub = uni_centro[297, 2])

  err <- which(uni_centro[, 'length'] == 0.000)
  uni_centro <- uni_centro[-c(err),]
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
  level_length <- uni_centro['length']

  level_plot <- ggplot(level_length, aes(length)) + geom_histogram(bins = n_centro)
  title = "Nombres d'occurrences des valeurs de distances inter-"
  tit <- str_glue("{title}{level_name[i]}")
  plot(level_plot + ggtitle(label = tit) + xlab("valeurs des distances") + ylab("Nombres d'occurrences"))

  liste <- vector(mode = 'list', length = n_centro)

  for (l in 1:n_centro)
  {
    wanted_tree <- as_tibble(tree_list[[l]])
    root <- which(is.na(wanted_tree['branch.length']) == TRUE)
    label <- which(tibble_tree$label %in% wanted_tree[root, 'label'])
    liste[l] <- tibble_tree[label, 'node']
  }

  liste <- t(as.data.frame(unique(liste)))
  type <- as.data.frame(matrix(data = 1:length(liste), nrow = length(liste), ncol = 1))
  liste <- cbind(liste, type)
  names(liste) <- c('node', 'type')

  level_tree <- ggtree(tree) + geom_hilight(data = liste, mapping = aes(node = node, fill = type))
  deb <- "sous-arbres "
  fin <- "/centroides"
  plot(level_tree + ggtitle(str_glue("{deb}{level_name[i]}{fin}")))

  liste_uni_centro[[i]] <- uni_centro
  liste_tree_liste[[i]] <- tree_list
}
