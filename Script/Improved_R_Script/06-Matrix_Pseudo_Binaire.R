library(tidyverse)

#### Ouverture de Sliced_ARG_Species.tsv & recuperation des donnees dans une dataframe ####
all_species <- read_tsv('W:/ninon-species/output/Output_M2/ARG/Dataframe/Sliced_ARG_Species.tsv') %>% 
  as.data.frame() # On ouvre le fichier sous la forme d une dataframe

#### Pretraitement des donnees en vue de la creation de matrices d absence/presence ARGxLevel d un genre un peu different... ####
level <- as.data.frame(all_species[, c(7:12)]) # On extrait le contenu des colonnes associes aux 6 niveaux taxonomiques etudies
level_name <- unlist(colnames(all_species[, c(7:12)])) # On extrait aussi leurs labels pour pouvoir travailler a un niveau donne plus facilement

uni_centro <- sort(unique(all_species$Centroid)) # On extrait la colonne des centroid en appliquant sort(unique()) dessus pour les trier en les dedoublonnant 
n_centro <- length(uni_centro) # On recupere le nombre de centroids distincts

for (i in 1:5) # Permet de parcourir les 5 niveaux taxonomiques etudies (d espece a classe)
{
  now_level <- as.data.frame(sort(unique(level[, i]))) # On extrait la colonne du niveau i en appliquant sort(unique()) dessus pour le trier en le dedoublonnant 
  colnames(now_level) <- level_name[i] # On renomme la colonne extraite pour faciliter son utilisation a venir
  
  for (j in (i + 1):6) # Permet de parcourir en parrallele du niveau i les j niveaux suivants
  {
    curr_level <- as.data.frame(unique(level[, c(j, i)])) # On extrait simultanement les colonnes des niveaux j et i en appliquant unique() dessus pour les dedoublonner (pas sort() parce qu on ne peut pas l appliquer a 2 colonnes en meme temps)
    na_level_1 <- which(is.na(curr_level[, 1]) == TRUE) # On isole les lignes du niveau j contenant NA (== valeur non renseignee)
    curr_level <- curr_level[-c(na_level_1),] # On supprimer ces lignes pour les 2 niveaux parce que leur presence genererait des erreurs par la suite 
    
    if (i > 1) # Si le niveau i n est pas celui des especes (et est donc succeptible de contenir des NA)
    {
      na_level_2 <- which(is.na(curr_level[, 2]) == TRUE) # On isole les lignes du niveau i contenant NA (== valeur non renseignee)
      curr_level <- curr_level[-c(na_level_2),] # On supprimer ces lignes pour les 2 niveaux parce que leur presence genererait des erreurs par la suite
    }
    
    curr_level %>%
      arrange_(level_name[j]) %>% # On reordonne a present les 2 colonnes en fonction de celle du niveau j pour finaliser leur pretraitement
      identity() -> curr_level
    
    uni_level <- unlist(as.data.frame(sort(unique(curr_level[, 1])))) # On extrait la colonne du niveau j pour apres
    n_level <- length(uni_level) # On recupere le nombre de representants distints du niveau j restant apres ces traitements successifs
    
    #### Preparation a l ouverture de la matrice binaire associee au niceau i depuis son fichier nominatif ####
    path_start = "W:/ninon-species/output/Output_M2/ARG/Matrice/Sliced_Matrix_" # Chemin d acces + debut de nom de fichier
    path_end = ".tsv" # Fin de nom de fichier (== extension du fichier)
    file_name = str_glue("{path_start}{level_name[i]}{path_end}") # Assemblage des 2 autour du label du niveau i pour obtenir le nom de fichier complet
    
    #### Ouverture & traitement de la matrice binaire associee au niveau i ####
    centro_matrix <- read_tsv(file_name) # On recupere les donnees du fichier correspondant a ladite matrice
    
    rownames(centro_matrix) <- uni_centro # On reassigne les labels de lignes (non conservables a l enregistrement)
    centro_matrix <- t(centro_matrix) # On transpose la matrice pour avoir les representants du niveau i en ligne le temps du join a venir   

    centro_matrix <- cbind(now_level, centro_matrix) # On fusionne la colonne du niveau i triee et dedoublonnee a notre matrice pour avoir une 1ere colonne identique aux labels de lignes actuels
    centro_matrix <- left_join(curr_level, centro_matrix, by = NULL) # On join les colonnes des niveaux j et i (d ou cet ordre !!) et la matrice sur les colonnes du niveau i de part et d autre (qui se fusionnent en une seule au passage)

    centro_matrix <- t(centro_matrix[,-2]) # On supprime la colonne du niveau i qui a remplit son office & on retranspose la matrice en passant
    colnames(centro_matrix) <- centro_matrix[1,] # On renomme les colonnes d apres le contenu de la ligne (anciennement colonne) du niveau j 

    centro_matrix <- as.data.frame(centro_matrix[-1,]) # On supprime la ligne du niveau j qui a egalement remplit son office & on en profite pour transformer la matrice en dataframe (necessaire pour pouvoir utiliser as.integer() dessus juste apres) 

    for (n in 1:ncol(centro_matrix)) # On parcourt les colonnes (autrement dit les representants du niveau j) de la desormais (mais pas pour longtemps) dataframe 
    {
      centro_matrix[, n] <- as.integer(c(centro_matrix[, n])) # On transforme le type du contenu de chaque colonnes en int (actuellement des str)
    } # N.B. : On a besoin d int pour la suite et on ne pouvait malheureusement pas appliquer as.integer() directement sur l ensemble de la matrice (sinon c est evidement ce que j aurais fait)
   
    centro_matrix <- as.matrix(centro_matrix) # On retransforme notre ex-matrice en matrice (parce que c est une matrice qu on veut au bout du compte)
    
    #### Creaction d une matrice pseudo-binaire (0/1~n) d absence/presence des genes de resistances au niveau i au sein du niveau j ####
    cross_matrix <- matrix(data = 0, nrow = n_centro, ncol = n_level) # Dimensionnee selon les 2 valeurs recuperee precedemment & remplie de 0 pour l instant
    rownames(cross_matrix) <- uni_centro # On associe les noms de centroids aux lignes
    colnames(cross_matrix) <- uni_level # Et ceux des representant du niveau j aux colonnes 

    for (k in 1:n_level) # On parcourt les k representants du niveau j distincts
    { 
      # La on va les chercher dans la colonne triee et dedoublonnee qu on extrait precedement
      to_set <- which(curr_level[, 1] %in% uni_level[k]) # On isole les occurrences du representant k au sein du bloc 'niveau j + niveau i' qu on a longuement pretraite precedement 
      l <- length(to_set) # On recupere le nombre d'occurrences trouvees
      m <- centro_matrix[, c(to_set)] # On extrait de notre matrice binaire les colonnes de meme indice que les occurences trouvees
      # Pour la colonne associe au representant k dans la matrice pseudo-binaire :
      if (l > 1) # S il y a plus d une occurrence
      {
        cross_matrix[, k] <- rowSums(m) # On lui assigne comme contenu la somme des colonnes extraites si-avant de la matrice binaire 
      }

      else # Sinon c est plus simple
      {
        cross_matrix[, k] <- m # On lui assigne comme contenu celui de l unique colonne extraite si-avant de la matrice binaire
      }
    } # N.B : Je sais c est un peu complique mais in fine ca donne un matrice ARGx'Level j' avec 0 s il y a pas de match ou le nombre de representants du niveau i au sein du representant du niveau j se partageant l ARG s il y a un match
    
    #### Enregistrement de la matrice pseudo-binaire ainsi obtenue dans un fichier nominatif ####
    path_start = "W:/ninon-species/output/Output_M2/ARG/Matrice/Sliced_Matrix_" # Chemin d acces + debut de nom de fichier
    path_end = ".tsv" # Fin de nom de fichier (== extension du fichier)
    new_file_name = str_glue("{path_start}{level_name[i]}_{level_name[j]}{path_end}") # Assemblage des 2 autour des labeles des niveau i et j pour obtenir le nom de fichier complet

    write.table(cross_matrix, new_file_name, sep = '\t', row.names = FALSE, col.names = TRUE) # Methode habituelle d enregistrement d une structure de type table dans un fichier
  }
}
