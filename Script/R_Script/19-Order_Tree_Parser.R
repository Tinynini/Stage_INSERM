library(tidyverse)
library(tidytree)
library(ape)
library(ggtree) 

#### Ouverture de Order.tree et de Taxo_result.tsv (ou de New_Taxo_result.tsv) & recuperation des donnees ####
tree <- read.tree('W:/ninon-species/output/Order_tree.tree')
tibble_tree <- as_tibble(tree)

all_species <- read_tsv('W:/ninon-species/output/Taxo_result.tsv') %>%
#all_species <- read_tsv('W:/ninon-species/output/New_Taxo_result.tsv') %>% 
  as.data.frame()

#### Pretraitement des donnees en vue de la creation d une matrice d absence/presence CentroidexOrdre ####
uni_centro <- sort(unique(all_species$Centroid))
n_centro <- length(uni_centro)

uni_order <- as.data.frame(sort(unique(all_species$Order)))
colnames(uni_order) <- 'Order'
n_order <- nrow(uni_order)

#### Creaction d une matrice binaire (0/1) d absence/presence des centroides au niveau des ordres ####
centro_matrix <- matrix(data = 0, nrow = n_centro, ncol = n_order)
rownames(centro_matrix) <- uni_centro

for (i in 1:n_centro) 
{
  curr_centro <- uni_centro[i]
  curr_order <- all_species[all_species$Centroid == curr_centro, 'Order']
  to_set <- which(uni_order[, 'Order'] %in% curr_order)
  centro_matrix[i, to_set] <- 1
}

centro_matrix <- t(centro_matrix)
centro_matrix <- as.data.frame(centro_matrix)
centro_matrix <- cbind(uni_order, centro_matrix)

#### Join de l arbre et de la matrice & preparation de nouvelles listes ####
tibble_tree <- left_join(tibble_tree, centro_matrix, by = c('label' = 'Order'))

n_ARG <- ncol(tibble_tree)
tree_list <- vector(mode = 'list', length = n_centro - 12)# Future liste des sous-arbres par centroides (12 = n_arbres_null obtenu restrospectivement)

length <- as.data.frame(matrix(data = 0, nrow = n_centro, ncol = 1))
uni_centro <- cbind(uni_centro, length) # Future dataframe des longueurs totales des sous-arbres par centroides
colnames(uni_centro) <- c('centroid', 'length')
j <- 1

#### Creation des listes des sous-arbres et de leurs longueurs par centroides ####
for (i in 5:n_ARG)  
{
  wanted_ARG <- colnames(tibble_tree[, i])
  wanted_tip <- tibble_tree$label[tibble_tree[wanted_ARG] == 1]
  wanted_tip <- na.omit(wanted_tip)
  
  tree_ARG <- keep.tip(tree, tip = wanted_tip)
  length <- sum(tree_ARG$edge.length)
  uni_centro[i - 4, 'length'] <- length
  
  if (is.null(tree_ARG) == FALSE)
  {
    tree_list[[j]] <- tree_ARG
    j <- j + 1
  }
}

err <- which(uni_centro[, 'length'] == 0.000)
uni_centro <- uni_centro[-c(err),]
names(tree_list) <- uni_centro[, 'centroid']
n_centro <- nrow(uni_centro)

#### Plot de l histogramme des distances ####
order_length <- uni_centro['length']
oplot <- ggplot(order_length, aes(length)) + geom_histogram(bins = n_centro)
oplot + ggtitle("Nombres d'occurrences des valeurs de distances inter-ordres") + xlab("valeurs des distances") + ylab("Nombres d'occurrences")

#### Exemple de plot d un sous_arbre avec "mef(B)_1_FJ196385" ####
plot.phylo(tree_list[[1251]], show.node.label = TRUE, main = uni_centro[1251, 1], sub = uni_centro[1251, 2])

#### Plot des sous-arbres des ordres par centroides sur l arbre complet ####
liste <- vector(mode = 'list', length = n_centro)

for (i in 1:n_centro)
{
  wanted_tree <- as_tibble(tree_list[[i]])
  root <- which(is.na(wanted_tree['branch.length']) == TRUE)
  label <- which(tibble_tree$label %in% wanted_tree[root, 'label'])
  liste[i] <- tibble_tree[label, 'node']
}

liste <- t(as.data.frame(unique(liste)))
type <- as.data.frame(matrix(data = 1:length(liste), nrow = length(liste), ncol = 1))
liste <- cbind(liste, type)
names(liste) <- c('node', 'type')

otree <- ggtree(tree) 
otree + ggtitle("arbre des ordres")

otree <- ggtree(tree) + geom_hilight(data = liste, mapping = aes(node = node, fill = type))
otree + ggtitle("sous-arbres des ordres par gènes")
