centro='/home/ninon.robin/alt_bash_script/output/centro.tsv'

Coli_species='/home/ninon.robin/alt_bash_script/output/Coli_species.tsv'
Salm_species='/home/ninon.robin/alt_bash_script/output/Salm.enter_species.tsv'
Klebs_species='/home/ninon.robin/alt_bash_script/output/Klebs.pneumo_species.tsv'
G_species='/home/ninon.robin/alt_bash_script/output/1G_species.tsv'
M_species='/home/ninon.robin/alt_bash_script/output/100M-1K_species.tsv'

Coli_share='/home/ninon.robin/alt_bash_script/output/Coli_share.tsv'
Salm_share='/home/ninon.robin/alt_bash_script/output/Salm.enter_share.tsv'
Klebs_share='/home/ninon.robin/alt_bash_script/output/Klebs.pneumo_share.tsv'
G_share='/home/ninon.robin/alt_bash_script/output/1G_share.tsv'
M_share='/home/ninon.robin/alt_bash_script/output/100M-1K_share.tsv'

past ${Coli_species} ${Salm_species} ${Klebs_species} ${G_species} ${M_species}  > /home/ninon.robin/alt_bash_script/output/matrix.tsv
paste ${centro} ${Coli_share} ${Salm_share} ${Klebs_share} ${G_share} ${M_share} | sed 's/\t//g' >> /home/ninon.robin/alt_bash_script/output/matrix.tsv