library(tidyverse)
library(tidytree)
library(ape)
library(ggtree) 

#### Ouverture de Species.tree et de Taxo_result.tsv (ou de New_Taxo_result.tsv) & recuperation des donnees ####
tree <- read.tree('W:/ninon-species/output/Species_tree.tree')
tibble_tree <- as_tibble(tree)

all_species <- read_tsv('W:/ninon-species/output/Taxo_result.tsv') %>%
#all_species <- read_tsv('W:/ninon-species/output/New_Taxo_result.tsv') %>% 
  as.data.frame()

#### Pretraitement des donnees en vue de la creation d une matrice d absence/presence CentroidexEspece ####
uni_centro <- sort(unique(all_species$Centroid))
n_centro <- length(uni_centro)

uni_species <- as.data.frame(sort(unique(all_species$species)))
colnames(uni_species) <- 'species'
n_species <- nrow(uni_species)

#### Creaction d une matrice binaire (0/1) d absence/presence des centroides au niveau des especes ####
centro_matrix <- matrix(data = 0, nrow = n_centro, ncol = n_species)
rownames(centro_matrix) <- uni_centro

for (i in 1:n_centro) 
{
  curr_centro <- uni_centro[i]
  curr_species <- all_species[all_species$Centroid == curr_centro, 'species']
  to_set <- which(uni_species[, 'species'] %in% curr_species)
  centro_matrix[i, to_set] <- 1
}

centro_matrix <- t(centro_matrix)
centro_matrix <- as.data.frame(centro_matrix)
uni_species[, 'species'] <- str_replace(uni_species[, 'species'], '(.*) (.*)', '\\1\\_\\2')
centro_matrix <- cbind(uni_species, centro_matrix)

#### Join de l arbre et de la matrice & preparation de nouvelles listes ####
tibble_tree <- left_join(tibble_tree, centro_matrix, by = c('label' = 'species'))

n_ARG <- ncol(tibble_tree)
tree_list <- vector(mode = 'list', length = n_centro - 59) # Future liste des sous-arbres par centroides (59 = n_arbres_null, obtenu restrospectivement)

length <- as.data.frame(matrix(data = 0, nrow = n_centro, ncol = 1))
uni_centro <- cbind(uni_centro, length) # Future dataframe des longueurs totales des sous-arbres par centroides
colnames(uni_centro) <- c('centroid', 'length')
j <- 1

#### Creation des listes des sous-arbres et de leurs longueurs totales par centroides ####
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
species_length <- uni_centro['length']
splot <- ggplot(species_length, aes(length)) + geom_histogram(bins = n_centro)
splot + ggtitle("Nombres d'occurrences des valeurs de distances inter-espèces") + xlab("valeurs des distances") + ylab("Nombres d'occurrences")

#### Exemple de plot d un sous_arbre avec "mef(B)_1_FJ196385" ####
plot.phylo(tree_list[[1209]], show.node.label = TRUE, main = uni_centro[1209, 1], sub = uni_centro[1209, 2])

#### Plot des sous-arbres des especes par centroides sur l arbre complet ####
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

stree <- ggtree(tree) 
stree + ggtitle("arbre des espèces")

stree <- ggtree(tree) + geom_hilight(data = liste, mapping = aes(node = node, fill = type))
stree + ggtitle("sous-arbres des espèces par gènes")
