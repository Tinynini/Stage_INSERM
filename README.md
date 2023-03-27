# Explication sur le contenu de ce github :

Ce github vous donne accès à l'ensemble des scripts R et bash (hors période d'entrainement) que j'ai codé lors de mon stage de M1 et de M2. Leurs numérotations permets de savoir dans quel ordres ils doivent être utilisés, ceux de M2 pouvants tous être lancés directement à partir du script main.R.

En revanche, par respect de la confidentialité qu'implique toute recherche scientifique, les données de départ et les outputs n'y figurent pas. Vous ne pourrez donc pas tester les codes par vous-même. Les scripts R sont duement légendés pour compenser cela. 

Quant aux scripts bash, leurs fonctionnements est décrit dans mon rapport dans la partie "Happy cluster à l’école des scripts bash" à travers 2 exemples :

- concat_ref4.sh (concat_all_ref.sh fonctione exactement de la même façon)
- cluster_fast_all.sh (cluster_size_all.sh, cluster_fast_FG.sh, cluster_size_FG.sh, cluster_fast_4.sh et cluster_size_4.sh fonctionnent selon le même principe)

Vous pouvez ouvrir les scripts bash en passant par un serveur LINUX, ou plus simplement dans Visual Code Studio ou toute autre plateforme permettant l'ouverture de fichier.txt (ou équivalent à ce format).

Vous pouvez retrouver les descriptions de tous ces scripts en annexe de mon rapport de stage dans la partie "Tout ce que vous avez toujours voulu savoir sur mes scripts...".

**N.B. :**

Pour les scripts de M1 (R_Script) :

Le script "All_species_cluster.R" génère à la fois un version complète et une version réduite de son output. Aussi, la plupart des autres scripts R sont conçus de ce fait pour pouvoir travailler soit en mode 'complet', soit en mode 'réduit'. Cela correspond à la présence de versions alternatives des lignes de code liées au chargement des données et d'enregistrement des outputs. Dans les 2 cas, la ligne du dessus permet de travailler avec la version complète et celle du dessous avec la version réduite. Il faut juste être vigilant à ce que le script soit régler sur la même version en entrée et en sortie. D'autres lignes de code internes aux scriptes peuvent parfois aussi nécessiter d'être commentées/décommentées en fonction de la version dans laquelle on souhaite travailler.

Selon ce même principe, le script "Taxonomy_Parser.R" permet de travailler soit à partir de la version prétraitée de la table de taxonomie (1ère version), soit à partir de la version originale (2nd version). Comme indiqué dans le script lui-même, une des lignes doit être décommentée et une autre plus loin commentée si l'on travaille avec la 1ère version, ou bien la 1ère de ces lignes commentée et l'autre décommentée si l'on travaille avec la 2nd version.

Pour les scripts de M2 (Improved_R_Script) :

On ne travaille plus qu'avec la version slicee de la dataframe puisque qu'on a eu la preuve avec les résultats obtenus en M1 que les 2 versions donnent bien les mêmes résultats de bout en bout. Par ailleurs, les scripts ayant été optimisés de différentes façon, les 2 versions de la table de taxonomie sont à présent générées simultatnément. 
