# TRADUCTOR DE LLIBRES EN CSV A PROLOG
# Desenvolupat per Markus Urban & Sergi Flores en el marc del recomanador de llibres, 2023 - 2024

import csv
from dateutil.parser import parse

# Nombre de llibres
max_lines = 100

with open('bestbooks.csv', encoding="utf8") as csv_file:

    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    
    for row in csv_reader:
        if line_count > max_lines:
            break
        else:
            try:

                # Definir l'idioma del llibre (English, French, Spanish, German)
                if row[5].strip() == "French":

                    year = parse(row[13], fuzzy=True).year
                    author = row[2].replace('(Goodreads Author)', '').split(',')[0].strip()
                    print(f'llibre("{row[0]}", \'{author}\', {row[3]}, "{row[5]}", {row[7]}, {row[8]}, {row[11]}, "{row[12]}", {year}, {row[19]}).')
                    line_count += 1
                
                    
            except:
                pass
            
