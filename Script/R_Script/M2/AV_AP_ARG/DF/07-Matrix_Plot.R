#library(tidyverse)

###################################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                                            #
# Utilite == generer les barplot de presence d un gene donne avec les 15 matrices #
# pseudo_binaires et le dendrogramme d un famille de gene donnee avec toutes      #
# Input == sliced_all_species_taxo.tsv et 21 fichiers Sliced_matrix_*.tsv         #
# Output == les 15 barplots (en FR et EN) et les 21 dendrogrammes                 #
###################################################################################

#### Ouverture de sliced_all_species_taxo.tsv & recuperation des donnees ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/AV_AP_ARG/Dataframe/sliced_all_species_taxo.tsv', col_types = "cccccccc") %>% 
  as.data.frame() 

uni_gene <- sort(unique(all_species$qseqid)) # On extrait la colonne des genes 

#### Obtention de la liste des fichiers contenant nos matrices binaires et pseudo-binaires ####
# On se rend dans le bon emplacement puis on recherche la parterne de nom de fichier 'Sliced_Matrix_.*.tsv' qui est commune aux 2 types de matrice 
all_matrix <- list.files(path = 'W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrice', pattern = 'Sliced_Matrix_.*.tsv', full.names = TRUE) 
n_matrix <- length(all_matrix) # On recupere le nombre de fichier contenus dans notre liste de fichier 
matrix_name <- str_replace(all_matrix, '(.*)(Matrix)_(.*).(tsv)', '\\3') # On recupere les noms de matrices a partir des noms de fichiers 

for (i in 1:n_matrix) # Permet de parcourir les matrices une par une
{
  gene_matrix <- read_tsv(file = all_matrix[i], show_col_types = FALSE) # On ouvre la matrice depuis la liste de fichier
  gene_matrix <- as.matrix(gene_matrix) 
  rownames(gene_matrix) <- uni_gene 
  
  #### Barplot de la presence d un gene donne (ici aac(6')-31_1_AM283489) ####
  # Pour definir les noms et destinations de fichiers pour l enregistrement
  deb_fr <- "W:/ninon-species/output/Output_M2/AV_AP_ARG/Plot/Matrice_plot/Barplot_Pres_ARG/rep/FR/Partage_inter-" 
  fin_fr <- "_fr.png" 
  deb_en <- "W:/ninon-species/output/Output_M2/AV_AP_ARG/Plot/Matrice_plot/Barplot_Pres_ARG/rep/EN/Partage_inter-" 
  fin_en <- "_en.png"
  # Pour definir les titres de barplots
  debut <- "Partage inter-" 
  fin <- " de " 
  start <- " inter-" 
  end <- " sharing"
  
  if (grepl('(.*)_(.*)', matrix_name[i]) == TRUE) # On ne fait ce plot que pour les matrices pseudo-binaires
  { # N.B. : Il suffit de changer l index dans gene_matrix et uni_gene et d adapter les chemins d acces pour tester un autre gene
    to_set <- which(gene_matrix[32,] != 0) # On isole les colonnes pour lesquelles le gene matche
    m <- gene_matrix[32, c(to_set)] # On extrait lesdites colonnes

    png(str_glue("{deb_fr}{matrix_name[i]}{fin_fr}"), height = 1017, width = 1920, pointsize = 20)
    barplot(m, main = str_glue("{debut}{matrix_name[i]}{fin}{uni_gene[32]}")) # Barblot de la presence du gene donne dans la matrice
    dev.off()
    
    png(str_glue("{deb_en}{matrix_name[i]}{fin_en}"), height = 1017, width = 1920, pointsize = 20)
    barplot(m, main = str_glue("{uni_gene[32]}{start}{matrix_name[i]}{end}")) # Barblot de la presence du gene donne dans la matrice
    dev.off()
  }
}
