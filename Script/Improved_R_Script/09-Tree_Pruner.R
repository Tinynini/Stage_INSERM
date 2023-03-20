library(tidyverse)
library(tidytree)
library(ape)

tree <- read.tree('W:/ninon-species/data/bac120/bac120_r95.tree')
tree_df <- as_tibble(tree)

all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_Taxo_Result.tsv') %>% 
  as.data.frame()

level_share <- as.data.frame(all_species[, c(6:18)])
level_share <- level_share[, -7]

for (i in 1:6)
{
  uni_level <- level_share[, c(i, i + 6)]
  colnames(uni_level) <- c('level', 'share')
  
  taxo <- read_tsv('W:/ninon-species/output/Table_taxonomie/New_Parsed_taxonomy.tsv') %>%
    as.data.frame()

  small_taxo <- taxo[, c(8, i)]

  taxo_tree <- left_join(tree_df, small_taxo, by = c('label' = 'sseqid'))
  taxo_tree[1:Ntip(tree), 'label'] <- taxo_tree[1:Ntip(tree), colnames(taxo[i])]
  taxo_tree <- taxo_tree[, -5]

  Label <- taxo_tree[1:Ntip(tree),]
  
  labels <- Label

  labels %>%
    arrange(label, parent) %>%
    group_by(label) %>%
    slice(1) -> labels

  labels <- rbind(labels)

  Label %>%
    arrange(node) %>%
    identity() -> Label

  labels %>%
    arrange(node) %>%
    identity() -> labels

  tips <- which((Label[, 'node'] %>% pull()) %in% (labels[, 'node'] %>% pull()) == FALSE)

  new_tree <- as.phylo(taxo_tree)
  new_tree <- drop.tip(new_tree, tips)
  taxo_tree <- as_tibble(new_tree)

  phylo_tree <- left_join(taxo_tree, uni_level, by = c('label' = 'level'))
  n_tips <- nrow(phylo_tree) - Nnode(new_tree)

  na_label <- is.na(phylo_tree[1:n_tips, 'share'])
  level <- which(na_label == FALSE)

  phylo_tree[level, 'share'] <- 1
  phylo_tree <- unique(phylo_tree)

  na_label <- is.na(phylo_tree[1:Ntip(new_tree), 'share'])
  level <- which(na_label == TRUE)

  next_tree <- as.phylo(phylo_tree)
  next_tree <- drop.tip(next_tree, level)
  phylo_tree <- as_tibble(next_tree)
  
  # Est ce qu on doit vraiment faire ca (est ce qu on peut s en passer) ??
  # phylo_tree %>%
  #   arrange(label) %>%
  #   identity -> phylo_tree
  # # C est pas une erreur le '__' ?
  # nodes_exclus = length(grep("(.*)__(.*)", unlist(phylo_tree[, 'label']))) + 1 
  # k <- 1
  #  
  # for (j in nodes_exclus:Nnode(next_tree)) 
  # {
  #   if(phylo_tree[j + 1, 'label'] == phylo_tree[j, 'label'])
  #   {
  #     phylo_tree[j, 'label'] <- str_glue("{phylo_tree[j, 'label']}_{k}")
  #     k <- k + 1
  #   }
  #   else
  #   {
  #     phylo_tree[j, 'label'] <- str_glue("{phylo_tree[j, 'label']}_{k}")
  #     k <- 1
  #   }
  # }
  # 
  # phylo_tree %>%
  #   arrange(node) %>%
  #   identity -> phylo_tree
  
  next_tree <- as.phylo(phylo_tree)

  path_start = "W:/ninon-species/output/Output_M2/ARG/Arbre/"
  path_end = ".tree"
  file_name = str_glue("{path_start}{colnames(level_share[i])}{path_end}")

  write.tree(next_tree, file_name)
}
