#wanted="Salm.enter"
#wanted="Klebs.pneumo"
#wanted="1G"
#wanted="100M-1"
#wanted="100M-2"
#wanted="10M"
#wanted="1M"
#wanted="100K"
#wanted="10K"
#wanted="1K"

./puzzle.sh "../data/Parsed_species/${wanted}.txt" \
            "../output/Puzzle_matrix/${wanted}_species.tsv" \
            "../output/Puzzle_matrix/${wanted}_share.tsv"
