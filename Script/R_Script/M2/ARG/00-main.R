library(tidyverse)
library(tidytree)
library(ape)
library(ggtree) 

if (file.exists('W:/ninon-species/output/Output_M2/ARG/Dataframe/all_species.tsv') == FALSE)
{
  source('W:/ninon-species/script/Script_M2/ARG/01-Species_filtering.R') # /!\ Ca prend 3/4h a 2h !!
} else if (file.exists('W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_all_species_clust.tsv') == FALSE)
{
  source('W:/ninon-species/script/Script_M2/ARG/02-All_species_cluster.R')
} else
{
  source('W:/ninon-species/script/Script_M2/ARG/03-Taxonomy_parser.R')
}

if (file.exists('W:/ninon-species/output/Output_M2/ARG/Dataframe/sliced_all_species_taxo.tsv') == FALSE)
{
  source('W:/ninon-species/script/Script_M2/ARG/04-Taxo_Join.R') 
} else 
{
  source('W:/ninon-species/script/Script_M2/ARG/05-Matrix_Binaire.R')
  source('W:/ninon-species/script/Script_M2/ARG/06-Matrix_Pseudo_Binaire.R')
  source('W:/ninon-species/script/Script_M2/ARG/07-Matrix_Plot.R')
  source('W:/ninon-species/script/Script_M2/ARG/08-Taxo_Filter_Plot.R')
  source('W:/ninon-species/script/Script_M2/ARG/09-Tree_Pruner.R')
  source('W:/ninon-species/script/Script_M2/ARG/10-Tree_Plot.R')
}
