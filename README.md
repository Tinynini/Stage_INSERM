# Explication sur le contenu de ce github :

Ce github vous donne accès à l'ensemble des scripts R et bash (hors période d'entrainement) que j'ai codé lors de mes stages de M1 et de M2. La numérotation des scripts R permet de savoir dans quel ordre ils doivent être utilisés, les scripts 00-main.R des 3 jeux de spripts de M2 permettant de lancer directement les autres scripts du même jeu.

En revanche, par respect de la confidentialité qu'implique toute recherche scientifique, les données de départ et les outputs n'y figurent pas. Vous ne pourrez donc pas tester les codes par vous-même. Les scripts sont duement légendés pour compenser cela. 

Vous pouvez ouvrir les scripts bash en passant par un serveur LINUX, ou plus simplement dans Visual Code Studio ou toutes autres plateformes permettant l'ouverture de fichier.txt (ou équivalant à ce format). 
Vous pouvez retrouver les descriptions de tous ces scripts en annexe de mes rapports de stages de M1 et M2 dans la partie "Tout ce que vous avez toujours voulu savoir sur mes scripts...".

**Les scripts bash de clustering :**

Il y a 2 types de scripts, ceux de concaténation de fichier propres à l'étude réalisée en M1, et ceux de clustering via VSearch en mode fast (par taille de séquence) et size (par abondance de séquence). Pour ces derniers, ceux labellisés '4' et 'FG' s'appliquent respectivement au fichiers de Resfinder4 et ResfinderFG (= données de M1), ceux labellisés 'all' aux 2 en même temps, et ceux labellisés 'gene' aux données de M2.

**Les scripts bash de sélection de gènes pour l'étude de M2 :**

Ces scripts sont propres à l'étude réalisée en M2. generater_liste_data.sh sert à prétraiter les données et doit donc être lancé en amont des autres. boss.sh permet d'effectuer d'un seul trait le travail sur les fichiers GFF et celui sur les fichiers FFN, tandis que boss_gff.sh et boss_ffn.sh permettent de les effectuer séparément. Dans la mesure où le travail sur les fichiers FFN utilise en input l'output du travail sur les fichiers GFF, boss_ffn.sh ne peut être lancé qu'après que boss_gff.sh ait fini de tourner. Le fichier ffn_parser.py est un script python qui permet de réaliser une étape du travail sur les fichier FFN qui n'étaient pas faisable en bash. Son lancement est effectué automatiquement à l'intérieur des scripts boss.sh et boss_ffn.sh lorsqu'on les fait tourner.

**Les scripts bash de réduction des données de M2 :**

Ces scripts sont propres à l'étude réalisée en M2. En raison du volume astronimique des données de M2, ce qui était auparavant effectué par les 2 premiers scripts R doit à présent l'être en bash. De plus, le volume des données est tel qu'il n'est possible à ce stade de les manipuler que sous forme de matrice, le passage à la forme de dataframe pouvant être fait ultérieurement en R. Le script data_parser.sh sert à prétraiter les données. Le script puzzle_coli.sh sert au traitement isolé du fichier Escherichia_Coli.tsv, le plus volumineux (et de loin !) du dataset. Le script puzzle.sh perment d'effectuer le même traitement de façon générique, à la façon d'une fonction, l'input et les outputs devant être définis au lancement. Le script puzzle_launcher.sh sert à lancer le scripts puzzle.sh sur 9 jeux d'input et d'output correspondant à 9 fractions successives du dataset. Enfin, le script puzzle_solver.sh sert à assembler les outputs des 9 fractions et d'E.coli en une unique matrice.

**Les scripts R de M1 :**

Ce jeu de scripts est conçu pour travailler avec les données propre à l'étude de M1, autrement dit celles se rapportant aux gènes de résistance (ARGs).

Le script "02-All_species_cluster.R" génère à la fois un version complète et une version réduite de son output. Aussi, la plupart des scripts suivant sont conçus de ce fait pour pouvoir travailler soit en mode 'complet', soit en mode 'réduit'. Cela correspond à la présence de versions alternatives des lignes de code liées au chargement des inputs et à l'enregistrement des outputs. Dans les 2 cas, la ligne du dessus permet de travailler avec la version complète et celle du dessous avec la version réduite. Il faut juste être vigilant à ce que le script soit réglé sur la même version en entrée et en sortie. D'autres lignes de code internes aux scriptes peuvent parfois aussi nécessiter d'être commentées/décommentées en fonction de la version dans laquelle on souhaite travailler.

Selon ce même principe, le script "03-Taxonomy_Parser.R" permet de travailler soit à partir de la version prétraitée de la table de taxonomie (1ère version), soit à partir de la version originale (2nde version). Comme indiqué dans le script lui-même, une des lignes doit être décommentée et une autre plus loin commentée si l'on travaille avec la 1ère version, ou bien la 1ère de ces lignes commentée et l'autre décommentée si l'on travaille avec la 2nde version.

**Les scripts R de M2 :**

Le dossier 'ARG' contient un jeu de scripts qui est la version optimisée de celui de M1. On ne travaille plus qu'avec la version réduite de la dataframe puisque qu'on a eu la preuve avec les résultats obtenus en M1 que les 2 versions donnent bien les mêmes résultats de bout en bout. Par ailleurs, les 2 versions de la table de taxonomie sont à présent générées simultannément, les matrices binaires et pseudo-binaires sont obtenues à tous les niveaux taxonomiques après (et non plus avant) récupération de la taxonomie en 2 scripts (un pour les matrices binaires, un pour les non-binaires), la-dite récupération de la taxonomie se fait en une seul script, tout comme l'obtention des arbres qui est à présent effectuée à tous les niveaux (jusqu'à l'ordre seulement avant). Idem pour le traitement des arbres et des matrices (un seul script à chaque fois pour le faire à tous les niveaux). Un nouveau script permet un traitement plus appronfondit des arbres et l'obtention de nouveaux graphes. 

Le dossier 'AV_AP_ARG' contient un jeu de scriptd conçu pour travailler avec les données propres à l'étude de M2, autrement dit celles se rapportant aux gènes avant/après ceux de résistance. Les 2 premières étapes (celles réalisées par les 2 premiers scripts R pour les ARGs) sont à présent réalisées en bash puis finalisées dans un unique script R, là encore en raison du volume astronomique des données de M2. Ce jeu de scripts est une variante de celui servant à traiter les ARGs, mais avec une toute nouvelle approche 100 % matricielle; Cette nouvelle approche s'est en effet révélée nécessaire toujours en raison du volume astronomique des données de M2. L'obtention des matrices binaires et pseudo-binaires se fait à présent avec un seul script.
