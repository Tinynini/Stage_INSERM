#library(tidyverse)

#########################################################################################
# Ninon ROBIN -- ninon.robin@inserm.fr                                                  #
# Utilite == generer les colonnes des partages inter-especes aux 6 niveaux taxonomiques #
# et les histogrammes des nombres d occurrence de valeurs de partages a chaque niveaux  #
# Input == sliced_all_species_taxo.tsv et taxo_species.tsv                              #
# Output == Les 6 histogrammes (en FR et EN)                                            #
#########################################################################################

#### Ouverture de sliced_all_species_taxo.tsv et taxo_species.tsv & recuperation des donnees ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/sliced_all_species_taxo.tsv', show_col_types = FALSE) %>% 
  as.data.frame()

species <- read_tsv('W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Dataframe/taxo_species.tsv', col_types = 'cccccc') %>% 
  as.data.frame() 

#### Recuperation des partages au 6 niveaux taxonomiques etudies ####
level_name <- unlist(colnames(species)) # On extrait les labels des 6 niveaux taxonomiques etudies pour pouvoir travailler a un niveau donne plus facilement
level_shared <- as.data.frame(matrix(data=0, nrow=nrow(all_species), ncol=6))

m_path_start <- "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Matrice/Sliced_Matrix_"
m_path_end <- ".tsv"

for (i in 1:6)
{
  m_file_name <- str_glue("{m_path_start}{level_name[i]}{m_path_end}") # Le nom de fichier est definit par une variable
  matrix <- read_tsv(m_file_name, show_col_types = FALSE)
  rownames(matrix) <- sort(all_species$qseqid)
  
  level_share <- as.data.frame(matrix(data=0, nrow=nrow(all_species), ncol=1))
  
  for (j in 1:nrow(matrix))
  {
    level_share[j, ] <- sum(matrix[j,])
  }
  
  level_shared[, i] <- level_share
}

#### Fonction pour generer les plots avec le titre et les labels en francais ####
generate_plot_fr <- function(shared_by, level_name)
{
  start <- 'Taxo_'
  end <- '_fr.png'
  title_start <- "Nombres d'occurrences des valeurs de partages inter-"
  path = "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Plot/Taxo_plot/FR"
  title <- str_glue("{title_start}{level_name}") # Le titre de l histogramme est definit par une variable
  ggplot(level_shared, aes(shared_by)) + geom_histogram(bins = max(shared_by)*2 - 1) + ggtitle(label = title) + xlab("Valeurs des partages") + ylab("Nombres d'occurences") 
  ggsave(str_glue("{start}{level_name}{end}"), plot = last_plot(), device = "png", path = path, width = 16, height = 8.47504)
}

#### Fonction pour generer les plots avec le titre et les labels en anglais ####
generate_plot_en <- function(shared_by, level_name)
{
  start <- 'Taxo_'
  end <- '_en.png'
  title_start <- "Inter-"
  title_end <- " sharing value occurences"
  path = "W:/ninon-species/output/Output_M2/AV_AP_ARG/Matrix/Plot/Taxo_plot/EN"
  title <- str_glue("{title_start}{level_name}{title_end}") # Le titre de l histogramme est definit par une variable
  ggplot(level_shared, aes(shared_by)) + geom_histogram(bins = max(shared_by)*2 - 1) + ggtitle(label = title) + xlab("Sharing values") + ylab("Number of occurences") 
  ggsave(str_glue("{start}{level_name}{end}"), plot = last_plot(), device = "png", path = path, width = 16, height = 8.47504)
}

#### histogrammes des nombres d occurrences des valeurs de partage aux 6 niveaux taxonomiques etudies ####
for (i in 1:6)
{
  shared_by <- level_shared[, i]
  generate_plot_fr(shared_by, level_name[i]) # On lui applique la fonction generate_plot_fr()
  generate_plot_en(shared_by, level_name[i]) # On lui applique la fonction generate_plot_en()
}
