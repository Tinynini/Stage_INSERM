centro='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/centro.tsv'
#centro='/home/ninon.robin/alt_bash_script/output/vib_centro.tsv'

Coli_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/Coli_species.tsv'
species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/species.tsv'
Salm_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/Salm.enter_species.tsv'
Klebs_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/Klebs.pneumo_species.tsv'
G_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/1G_species.tsv'
#M_100_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/100M_species.tsv'
M_100_1_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/100M-1_species.tsv'
M_100_2_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/100M-2_species.tsv'
M_10_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/10M_species.tsv'
M_1_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/1M_species.tsv'
K_100_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/100K_species.tsv'
K_10_species='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/10K-1K_species.tsv'

Coli_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/Coli_share.tsv'
Salm_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/Salm.enter_share.tsv'
Klebs_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/Klebs.pneumo_share.tsv'
G_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/1G_share.tsv'
#M_100_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/100M_share.tsv'
M_100_1_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/100M-1_share.tsv'
M_100_2_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/100M-2_share.tsv'
M_10_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/10M_share.tsv'
M_1_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/1M_share.tsv'
K_100_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/100K_share.tsv'
K_10_share='/home/ninon.robin/alt_bash_script/output/Puzzle_matrix/10K-1K_share.tsv'

paste ${Coli_species} ${Salm_species} ${Klebs_species} ${G_species} ${M_100_1_species} ${M_100_2_species} ${M_10_species} ${M_1_species} ${K_100_species} ${K_10_species} | sed 's/\t//g' > /home/ninon.robin/alt_bash_script/output/full_matrix.tsv
paste ${centro} ${Coli_share} ${Salm_share} ${Klebs_share} ${G_share} ${M_100_1_share} ${M_100_2_share} ${M_10_share} ${M_1_share} ${K_100_share} ${K_10_share} | sed 's/\t//g' >> /home/ninon.robin/alt_bash_script/output/full_matrix.tsv
#paste ${species} ${Salm_species} ${Klebs_species} ${G_species} ${M_100_1_species} ${M_100_2_species} ${M_10_species} ${M_1_species} ${K_100_species} ${K_10_species} | sed 's/\t//g' > /home/ninon.robin/alt_bash_script/output/pseudo_matrix.tsv
#paste ${centro} ${Salm_share} ${Klebs_share} ${G_share} ${M_100_1_share} ${M_100_2_share} ${M_10_share} ${M_1_share} ${K_100_share} ${K_10_share} | sed 's/\t//g' >> /home/ninon.robin/alt_bash_script/output/pseudo_matrix.tsv
