#wanted="Salm.enter"
#wanted="Klebs.pneumo"
#wanted="1G"
#wanted="100M-1K"
#wanted="100M-100K"
#wanted="100M-10M"
#wanted="1M-100K"
#wanted="10K-1K"

./puzzle.sh "../data/Parsed_species/${wanted}.txt" \
            "../output/Puzzle_matrix/${wanted}_species.tsv" \
            "../output/Puzzle_matrix/${wanted}_share.tsv"
