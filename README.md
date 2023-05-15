# Explication sur le contenu de ce github :

Ce github vous donne accès à l'ensemble des scripts R et bash (hors période d'entrainement) que j'ai codé lors de mes stages de M1 et de M2. Leurs numérotations permets de savoir dans quel ordres ils doivent être utilisés, ceux de M2 pouvants tous être lancés directement à partir du script 00-main.R.

En revanche, par respect de la confidentialité qu'implique toute recherche scientifique, les données de départ et les outputs n'y figurent pas. Vous ne pourrez donc pas tester les codes par vous-même. Les scripts sont duement légendés pour compenser cela. 

Vous pouvez ouvrir les scripts bash en passant par un serveur LINUX, ou plus simplement dans Visual Code Studio ou toutes autres plateformes permettant l'ouverture de fichier.txt (ou équivalant à ce format).
Vous pouvez retrouver les descriptions de tous ces scripts en annexe de mes rapports de stages de M1 et M2 dans la partie "Tout ce que vous avez toujours voulu savoir sur mes scripts...".

**Les scripts bash de clustering :**

Il y a 2 types de scripts, ceux de concaténation de fichier propre à l'étude réalisée en M1, et ceux de clustering via VSearch en mode fast (par taille de séquence) et size (par abondance de séquence). Pour ces derniers, ceux labélisés '4' et 'FG' s'appliquent respectivement au fichiers de Resfinder4 et ResfinderFG, ceux labélisés 'all' aux 2 en même temps, et ceux labélisés 'gene' aux donnés propre à l'étude réalisée en M2.

**Les scripts bash de sélection de gènes :**

Ces scripts sont propre à l'étude réalisée en M2. generater_liste_data.sh sert à prétraiter les données et doit donc être lancer en amont des autres. boss.sh permet d'effectuer d'un seul trait le travail sur les fichiers GFF et celui sur les fichiers FFN, tandis que boss_gff.sh et boss_ffn.sh permettent de les effectuer séparément. Dans la mesure où le travail sur les fichiers FFN utilise en input l'output du travail sur les fichiers GFF, boss_ffn.sh ne peut être lancer qu'après que boss_gff.sh ai fini de tourner. Le fichier ffn_parser.py est un script python qui permet de réaliser une étape du travail sur les fichier FFN qui n'étaient pas faisable en bash. Son lancement est effectué automatiquement à l'intérieur des scripts boss.sh et boss_ffn.sh lorsqu'on les fait tourner.

**Les scripts R de M1 :**

Le script "All_species_cluster.R" génère à la fois un version complète et une version réduite de son output. Aussi, la plupart des autres scripts R sont conçus de ce fait pour pouvoir travailler soit en mode 'complet', soit en mode 'réduit'. Cela correspond à la présence de versions alternatives des lignes de code liées au chargement des données et d'enregistrement des outputs. Dans les 2 cas, la ligne du dessus permet de travailler avec la version complète et celle du dessous avec la version réduite. Il faut juste être vigilant à ce que le script soit régler sur la même version en entrée et en sortie. D'autres lignes de code internes aux scriptes peuvent parfois aussi nécessiter d'être commentées/décommentées en fonction de la version dans laquelle on souhaite travailler.

Selon ce même principe, le script "Taxonomy_Parser.R" permet de travailler soit à partir de la version prétraitée de la table de taxonomie (1ère version), soit à partir de la version originale (2nde version). Comme indiqué dans le script lui-même, une des lignes doit être décommentée et une autre plus loin commentée si l'on travaille avec la 1ère version, ou bien la 1ère de ces lignes commentée et l'autre décommentée si l'on travaille avec la 2nde version.

**Les scripts R de M2 :**

On ne travaille plus qu'avec la version slicee de la dataframe puisque qu'on a eu la preuve avec les résultats obtenus en M1 que les 2 versions donnent bien les mêmes résultats de bout en bout. Par ailleurs, les scripts ayant été optimisés de différentes façon, les 2 versions de la table de taxonomie sont à présent générées simultatnément. 

Par ailleurs, les 2 premières étapes (celles réalisées par les 2 premiers scripts R en M1) sont a présents réaliser en bash, le volume des nouvelles données étant beaucoup trop important pour R Studio.
