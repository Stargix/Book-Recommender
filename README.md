# Prolog Book Recommender
This project is a book recommender with prolog with a clear UI

# Description
The recommender is based on a database of 400 books with up to 13 parameters 
that thanks to a user creator can sugest interesting books depending on the preferences

# Commands
- help -> shows commands
- start -> starts the recommendation
- crear -> creates a new user
- usuaris -> shows all users
- batch -> processes multiple users
- busca -> searches on database

# Structure

## Users 
    usuari(nom_usuari, Nom, Cognom, Edat, Gèneres, [Edició_posterior, Edició_anterior],
    [Extensió_mínima, Extensió_màxima], LlocsNoVol, AutorsNoVol, Idiomes, AutorsSiVol,
    LlocsSiVol, GèneresNoVol, Recomanacions).

    -A unique identifier
    -First name
    -Last name
    -Age
    -Genres of interest
    -Latest publication year
    -Earliest publication year
    -Minimum length
    -Maximum length
    -Undesired settings
    -Undesired authors
    -Languages
    -Authors of interest
    -Locations of interest
    -Genres to avoid
    -Previous recommendations

## Books
    llibre("Les Misérables", "Victor Hugo", 4.18, "English", ['Classics',
'Fiction', 'Historical Fiction', 'Literature', 'France', 'Historical',
'Novels', 'French Literature', 'Romance', 'Classic Literature'], ['Jean
Valjean', 'Javert', 'Cosette', 'Fantine', 'Bishop Myriel', 'M. & Mme.
Thénardier', 'Marius Pontmercy', 'Enjolras', 'Éponine', 'Gavroche',
'Azelma', 'Champmathieu', 'Fauchelevent', 'Grantaire', 'Mademoiselle
Gillenorman', 'Felix Tholomyès', 'Toussaint', 'Combeferre', 'Jean
Valjean, Javert, Fantine, Cosette, Marius Pontmercy', 'Jean Valjean',
'Police Inspector Javert', 'Cosette', 'Fantine', 'Marius Pontmercy',
'Éponine', 'Enjolras', 'Gavroche', 'Bishop of Digne', 'Grantaire',
'Bahorel', 'Bossuet'], 1463, "Signet Classics", 1987, ['Paris
(France)']).

    -Title of the book
    -Author
    -Rating
    -Language
    -Genres
    -Characters
    -Number of pages
    -Publisher
    -Year of publication
    -Locations of the action
