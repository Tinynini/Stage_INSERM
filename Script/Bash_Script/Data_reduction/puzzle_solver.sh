centro='/home/ninon.robin/alt_bash_script/output/centro.tsv'

Coli_species='/home/ninon.robin/alt_bash_script/output/Coli_species.tsv'
Salm_species='/home/ninon.robin/alt_bash_script/output/Salm.enter_species.tsv'
Klebs_species='/home/ninon.robin/alt_bash_script/output/Klebs.pneumo_species.tsv'
G_species='/home/ninon.robin/alt_bash_script/output/1G_species.tsv'
M_100-10_species='/home/ninon.robin/alt_bash_script/output/100M-10M_species.tsv'
K_1000-100_species='/home/ninon.robin/alt_bash_script/output/1M-100K_species.tsv'
K_10-1_species='/home/ninon.robin/alt_bash_script/output/10K-1K_species.tsv'

Coli_share='/home/ninon.robin/alt_bash_script/output/Coli_share.tsv'
Salm_share='/home/ninon.robin/alt_bash_script/output/Salm.enter_share.tsv'
Klebs_share='/home/ninon.robin/alt_bash_script/output/Klebs.pneumo_share.tsv'
G_share='/home/ninon.robin/alt_bash_script/output/1G_share.tsv'
M_100-10_share='/home/ninon.robin/alt_bash_script/output/100M-10M_share.tsv'
K_1000-100_share='/home/ninon.robin/alt_bash_script/output/1M-100K_share.tsv'
K_10-1_share='/home/ninon.robin/alt_bash_script/output/10K-1K_share.tsv'

paste ${Coli_species} ${Salm_species} ${Klebs_species} ${G_species} ${M_100-10_species} ${K_1000-100_species} ${K_10-1_species} > /home/ninon.robin/alt_bash_script/output/matrix.tsv
paste ${centro} ${Coli_share} ${Salm_share} ${Klebs_share} ${G_share} ${M_100-10_share} ${K_1000-100_share} ${K_10-1_share} | sed 's/\t//g' >> /home/ninon.robin/alt_bash_script/output/matrix.tsv
