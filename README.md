Ce github vous donne accès à l'ensembles des scripts R et bash que j'ai codé lors de mon stage de M1. En revanche, par respect de la confidentialité qu'implique toutes recherches scientifiques, les données de départ et les outputs n'y figurent pas. Vous ne pourrez donc pas tester les codes par vous même, mais les scripts R sont duement légendés pour compenser cela. Quant aux scripts bash, leur fonctionnement est décrit dans mon rapport dans la partie "1) Happy cluster à l’école des scripts bash" (sous-partie de la partie "III – Partie expérimentale, quand l’affaire tourne aux codes…").

Le fichier "Doc de travail.pdf" au début de ce github contient la description de l'ensemble des datasets, scripts et outputs.

Vous pouvez également retrouver ces mêmes descriptions dans la Partie "II – Matériels & Méthodes, les origines du code" -> "1) Par ici la donnée !" (pour les données) et dans la partie "V – Annexes" -> "2) Demandez le programme !" (pour les scripts et les outputs) de mon rapport de stage.

L'ensembles des outputs générés sont disponibles sur ce github pour vous permettre de tester les scripts à votre guise. Ils vous suffit de tout télécharger (données, scripts et outputs), et de modifier les chemin d'accès des fichiers utilisés en input et généré en output d'un script donné avant de le faire tourner.

/!\ Attention : Le script "Species_filtering.R" a un temps de process de près de 3/4h avec un ordinateur de bureau (tour d'ordinateur), et de plus de 1h30 avec un ordinateur portable 64 Bits. Aussi, je vous invite à ne tester ce script que sur une partie des données de départ, en modifiant le code pour le faire tourner sur les n premiers fichiers (n > ou = 1500 pour avoir un nombre suffisant de fichiers non vides) de chacun des 2 dossiers en input.

Le script All_species_cluster.R génèré à la fois un version complète et une version réduite de son output. À l'exception de "Species_filtering.R" qui s'utilise en amont, et de "Taxonomy_Parser.R" qui n'utilise que la table de taxonomie, les scripte R sont conçu pour pouvoir travailler soit en mode 'complet', soit en mode 'réduit'. Au moment de charger l'output du script précédents

Cela correspond aux versions alternatives des lignes de code lié chargement des données et d'enregistrement des outputs, 2 versions vous sont proposés il vous suffit de retirer les '#' devant et d'en même à la place sur les lignes du dessus pour passer de la version complète à celle réduite. Pensez là aussi à modifier les chemins d'accès au même titre que pour la version complète.

Les autres scripts R ont tous des temps de process raisonnables, mais qui restent tout de même un peu long au cumulé, aussi je vous invite à les tester sur les outputs réduits plutôt que sur les outputs complets.

Vous pouvez ouvrir les scripts bash sur Visual Code Studio ou toute autre plateforme permettant l'ouverture de fichier.txt (ou équivalent à ce format), mais ils ne peuvent tourner que depuis un serveur linux. Vous pouvez aussi passez par une marchine vituelle Linux telle que Oracle VM VirtualBox. Vous devez également installer VSearch en suivant les consignes proposer sur https://github.com/torognes/vsearch, et le lancer en faisant tourner le script "start.sh" pour pouvoir tester les scripts de clustering (les 6 qui commencent par "cluster_").

Si vous deviez faire tourner ces scripts (R ou bash) à partir des seuls datasets de départ et des output générés par ceux-ci au fur et à mesure de leur utilisation, il vous faudrait alors respecter les consignes qui suivantes.

Pour la partie clustering (scripts bash) :

Comme précedemment, vous devez avoir installé VSearch en amont, puis l'avoir démarrer en faisant tourner "start.sh".

Vous devez faire tourner "concat_ref4.sh" avant de pouvoir tester "concat_all_ref.sh", "cluster_fast_4.sh" et "cluster_size_4.sh", puisqu'ils utilisent tous les 3 en input l'output du ce premier script. Vous pouvez en revanche tester directement "cluster_fast_FG.sh" et "cluster_size_FG.sh", leur input étant déjà disponible dans le dataset de départ. Enfin, "cluster_fast_all.sh" et "cluster_size_all.sh" doivent être tester après avoir fait tourner "concat_all_ref.sh" dont ils utilisent l'output en input.

Pour la partie de traitement de donnée (scripts R) :

Pour les raison déjà évoqué précédemment, je vous invite à partir directement de l'output "all_species.tsv' et du script "All_species_cluster.R".

Les autres scripts ont tous des temps de process raisonnables, mais qui restent tout de même un peu long au cumulé, aussi je vous invite à les tester sur les outputs réduits plutôt que sur les véritables outputs.
